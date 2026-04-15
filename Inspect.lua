-- Inspect.lua — Queue engine for inspecting all raid members
-- Manages NotifyInspect throttle, INSPECT_READY handling, timeout, and progress.

RaidInspectorInspect = {}
local I = RaidInspectorInspect

local THROTTLE_SEC = 1.2   -- min seconds between NotifyInspect calls
local TIMEOUT_SEC  = 3.0   -- seconds to wait for INSPECT_READY before skipping

-- ── State ─────────────────────────────────────────────────────────────────────

local queue        = {}    -- ordered list of unit tokens: {"raid1", "raid2", ...}
local current      = 0     -- index of item currently being inspected
local isScanning   = false
local lastNotify   = 0     -- GetTime() of last NotifyInspect call
local timeoutTimer = nil   -- C_Timer handle (or our fallback frame ticker)

-- ── Timer abstraction ─────────────────────────────────────────────────────────
-- C_Timer.After was backported to TBC Classic 2.5.x but we provide an OnUpdate
-- fallback just in case. The fallback reuses a single frame to avoid leaking
-- one frame per CallAfter invocation.

local tickerFrame      = nil   -- single reused frame for the OnUpdate fallback
local tickerTarget     = 0     -- absolute time() + seconds when callback fires
local tickerCallback   = nil   -- pending callback

local function CallAfter(seconds, fn)
    if C_Timer and C_Timer.After then
        C_Timer.After(seconds, fn)
    else
        -- Lazily create a single ticker frame
        if not tickerFrame then
            tickerFrame = CreateFrame("Frame")
            tickerFrame:SetScript("OnUpdate", function(self, dt)
                if tickerCallback and GetTime() >= tickerTarget then
                    local cb = tickerCallback
                    tickerCallback = nil
                    self:Hide()
                    cb()
                end
            end)
        end
        tickerCallback = fn
        tickerTarget   = GetTime() + seconds
        tickerFrame:Show()
    end
end

-- ── Timeout tracking ──────────────────────────────────────────────────────────

local timeoutFired = false

local function CancelTimeout()
    timeoutFired = true  -- mark stale so the pending timer is a no-op when it fires
end

local function SetTimeout(seconds, fn)
    timeoutFired = false
    local generation = {}  -- unique table reference per timeout
    local myGeneration = generation
    I._timeoutGeneration = generation

    CallAfter(seconds, function()
        -- Only fire if this is still the active timeout (not cancelled/replaced)
        if I._timeoutGeneration == myGeneration and not timeoutFired then
            fn()
        end
    end)
end

-- ── Public API ────────────────────────────────────────────────────────────────

function I.StartScan()
    if not IsInGroup() then return end

    I.StopScan()

    -- Build queue: all group members except self
    queue   = {}
    current = 1

    local inRaid = IsInRaid()
    local n = GetNumGroupMembers()
    for i = 1, n do
        local token = inRaid and ("raid" .. i) or ("party" .. i)
        if UnitExists(token) and not UnitIsUnit(token, "player") then
            table.insert(queue, token)
        end
    end

    -- Harvest self immediately — no NotifyInspect needed
    RaidInspectorData.HarvestSelf()

    isScanning = true
    lastNotify = 0

    RaidInspector.Fire("SCAN_UPDATED", 0, #queue)
    I.AdvanceQueue()
end

function I.StopScan()
    isScanning = false
    CancelTimeout()
    queue   = {}
    current = 0
end

function I.IsScanning()
    return isScanning
end

function I.GetProgress()
    return math.max(0, current - 1), #queue
end

-- ── Queue advancement ─────────────────────────────────────────────────────────

function I.AdvanceQueue()
    if not isScanning then return end

    if current > #queue then
        -- All done
        isScanning = false
        CancelTimeout()
        local total = RaidInspectorData.PlayerCount()
        RaidInspector.Fire("SCAN_COMPLETE", total)
        return
    end

    local unit = queue[current]

    -- Skip offline players
    if not UnitIsConnected(unit) then
        local name, realm = UnitName(unit)
        if name then
            RaidInspectorData.StoreOffline(name, realm)
        end
        current = current + 1
        RaidInspector.Fire("SCAN_UPDATED", current - 1, #queue)
        I.AdvanceQueue()  -- immediate recursive advance (no throttle for offline)
        return
    end

    -- Throttle: ensure minimum time since last NotifyInspect
    local now = GetTime()
    local elapsed = now - lastNotify
    if elapsed < THROTTLE_SEC and lastNotify ~= 0 then
        CallAfter(THROTTLE_SEC - elapsed, I.AdvanceQueue)
        return
    end

    -- Start timeout watchdog before NotifyInspect
    local unitAtDispatch = unit
    SetTimeout(TIMEOUT_SEC, function()
        if isScanning and queue[current] == unitAtDispatch then
            local name, realm = UnitName(unitAtDispatch)
            if name then
                RaidInspectorData.StoreTimeout(name, realm)
            end
            current = current + 1
            RaidInspector.Fire("SCAN_UPDATED", current - 1, #queue)
            I.AdvanceQueue()
        end
    end)

    lastNotify = GetTime()
    NotifyInspect(unit)
end

-- ── Inspect single target ────────────────────────────────────────────────────
-- Inspect the current target (can be used outside of a group).

function I.InspectTarget()
    if not UnitExists("target") then
        print("|cff00ccff[TRI]|r No target selected.")
        return
    end
    if not UnitIsPlayer("target") then
        print("|cff00ccff[TRI]|r Target is not a player.")
        return
    end
    if UnitIsUnit("target", "player") then
        -- Just harvest self
        RaidInspectorData.HarvestSelf()
        RaidInspector.Fire("SCAN_UPDATED")
        RaidInspector.Fire("SCAN_COMPLETE", 1)
        return
    end
    if not CheckInteractDistance("target", 1) then
        print("|cff00ccff[TRI]|r Target is too far away to inspect.")
        return
    end

    I.StopScan()

    queue   = { "target" }
    current = 1
    isScanning = true
    lastNotify = GetTime()

    -- Start timeout watchdog
    SetTimeout(TIMEOUT_SEC, function()
        if isScanning and queue[current] == "target" then
            local name = UnitName("target")
            if name then
                RaidInspectorData.StoreTimeout(name, nil)
            end
            isScanning = false
            RaidInspector.Fire("SCAN_UPDATED")
            print("|cff00ccff[TRI]|r Inspect timed out.")
        end
    end)

    NotifyInspect("target")
end

-- ── INSPECT_READY handler ─────────────────────────────────────────────────────
-- Called by RaidInspector.lua's OnEvent dispatch.
-- Argument: guid of the unit whose inspection data is now available.

function I.OnInspectReady(guid)
    if not isScanning then return end
    if current > #queue then return end

    local unit = queue[current]

    -- GUID validation: ignore stale events from units other than the current target
    if UnitGUID(unit) ~= guid then
        -- Could be a manual inspect by the user — just ignore and keep waiting
        return
    end

    -- Cancel the timeout watchdog
    CancelTimeout()

    -- Harvest gear and talent data synchronously while inspect data is fresh
    RaidInspectorData.HarvestInspectData(unit)

    current = current + 1
    RaidInspector.Fire("SCAN_UPDATED", current - 1, #queue)

    -- Throttle before next inspect
    local now     = GetTime()
    local elapsed = now - lastNotify
    local delay   = math.max(0, THROTTLE_SEC - elapsed)

    CallAfter(delay, I.AdvanceQueue)
end
