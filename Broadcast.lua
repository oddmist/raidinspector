-- Broadcast.lua — Whisper and raid-announce gear issues
-- Uses SendChatMessage API: WHISPER for individual players, RAID for raid-wide.
-- Messages are throttled (0.5s apart) to avoid disconnect from chat spam.

RaidInspectorBroadcast = {}
local BC = RaidInspectorBroadcast
local L  = RaidInspectorL
local D  = RaidInspectorData

local SEND_INTERVAL = 0.5   -- seconds between SendChatMessage calls
local MAX_MSG_LEN   = 255   -- WoW's max chat message length

-- ── Message queue + throttled send ────────────────────────────────────────────

local sendQueue     = {}
local sendTimer     = nil
local isSending     = false

local function ProcessQueue()
    if #sendQueue == 0 then
        isSending = false
        return
    end
    isSending = true
    local entry = table.remove(sendQueue, 1)
    SendChatMessage(entry.msg, entry.channel, nil, entry.target)

    if C_Timer and C_Timer.After then
        C_Timer.After(SEND_INTERVAL, ProcessQueue)
    else
        -- Fallback for missing C_Timer
        local f = CreateFrame("Frame")
        local elapsed = 0
        f:SetScript("OnUpdate", function(self, dt)
            elapsed = elapsed + dt
            if elapsed >= SEND_INTERVAL then
                self:SetScript("OnUpdate", nil)
                ProcessQueue()
            end
        end)
    end
end

local function QueueMessage(msg, channel, target)
    -- Split long messages for whisper
    if #msg > MAX_MSG_LEN then
        while #msg > 0 do
            local chunk = msg:sub(1, MAX_MSG_LEN)
            table.insert(sendQueue, { msg=chunk, channel=channel, target=target })
            msg = msg:sub(MAX_MSG_LEN + 1)
        end
    else
        table.insert(sendQueue, { msg=msg, channel=channel, target=target })
    end

    if not isSending then
        ProcessQueue()
    end
end

-- ── Build messages from player record ─────────────────────────────────────────

-- Build a whisper message for one player. Returns a string or nil (no issues).
function BC.BuildWhisperMessage(record)
    if not record then return nil end
    if record.status == "ok" or record.status == "unscanned"
       or record.status == "offline" or record.status == "timeout" then
        return nil
    end

    local parts = {}

    -- Collect slot-level issues
    local missingEncSlots = {}
    local wrongEncSlots   = {}
    local missingGemSlots = {}
    local lowGemSlots     = {}

    for _, slotId in ipairs(D.ALL_SLOTS) do
        local slot = record.slots and record.slots[slotId]
        if slot then
            if slot.enchantMissing then
                table.insert(missingEncSlots, RaidInspectorUIUtil.SlotName(slotId))
            elseif slot.enchantWrong then
                table.insert(wrongEncSlots, RaidInspectorUIUtil.SlotName(slotId))
            end
            if slot.gemsMissing then
                table.insert(missingGemSlots, string.format(L["MSG_GEM_DETAIL"],
                    RaidInspectorUIUtil.SlotName(slotId), slot.gemsFilled, slot.gemSlotsExpected))
            end
            if slot.gemsLowQuality then
                table.insert(lowGemSlots, RaidInspectorUIUtil.SlotName(slotId))
            end
        end
    end

    if #missingEncSlots > 0 then
        table.insert(parts, string.format(L["MSG_MISSING_ENC"], table.concat(missingEncSlots, ", ")))
    end
    if #wrongEncSlots > 0 then
        table.insert(parts, string.format(L["MSG_WRONG_ENC"], table.concat(wrongEncSlots, ", ")))
    end
    if #missingGemSlots > 0 then
        table.insert(parts, string.format(L["MSG_MISSING_GEMS"], table.concat(missingGemSlots, ", ")))
    end
    if #lowGemSlots > 0 then
        table.insert(parts, string.format(L["MSG_LOW_GEMS"], table.concat(lowGemSlots, ", ")))
    end

    if #parts == 0 then return nil end
    return L["WHISPER_PREFIX"] .. " " .. table.concat(parts, ". ") .. "."
end

-- Build announce lines for one player. Returns a list of strings, or nil (no issues).
-- Uses slot names inline (same detail as whisper) so readers know which slots are bad.
function BC.BuildAnnounceLines(record)
    if not record then return nil end
    if record.status == "ok" or record.status == "unscanned"
       or record.status == "offline" or record.status == "timeout" then
        return nil
    end

    -- Build slot-level detail (same as whisper)
    local missingEncSlots = {}
    local wrongEncSlots   = {}
    local missingGemSlots = {}
    local lowGemSlots     = {}

    for _, slotId in ipairs(D.ALL_SLOTS) do
        local slot = record.slots and record.slots[slotId]
        if slot then
            if slot.enchantMissing then
                table.insert(missingEncSlots, RaidInspectorUIUtil.SlotName(slotId))
            elseif slot.enchantWrong then
                table.insert(wrongEncSlots, RaidInspectorUIUtil.SlotName(slotId))
            end
            if slot.gemsMissing then
                table.insert(missingGemSlots, string.format(L["MSG_GEM_DETAIL"],
                    RaidInspectorUIUtil.SlotName(slotId), slot.gemsFilled, slot.gemSlotsExpected))
            end
            if slot.gemsLowQuality then
                table.insert(lowGemSlots, RaidInspectorUIUtil.SlotName(slotId))
            end
        end
    end

    local parts = {}
    if #missingEncSlots > 0 then
        table.insert(parts, string.format(L["MSG_MISSING_ENC"], table.concat(missingEncSlots, ", ")))
    end
    if #wrongEncSlots > 0 then
        table.insert(parts, string.format(L["MSG_WRONG_ENC"], table.concat(wrongEncSlots, ", ")))
    end
    if #missingGemSlots > 0 then
        table.insert(parts, string.format(L["MSG_MISSING_GEMS"], table.concat(missingGemSlots, ", ")))
    end
    if #lowGemSlots > 0 then
        table.insert(parts, string.format(L["MSG_LOW_GEMS"], table.concat(lowGemSlots, ", ")))
    end

    if #parts == 0 then return nil end

    -- Build the full message, splitting into multiple lines if needed
    local detail = table.concat(parts, ". ")
    local full   = string.format(L["ANNOUNCE_LINE"], record.name, detail)
    local lines  = {}

    -- Chunk into MAX_MSG_LEN lines if needed
    while #full > MAX_MSG_LEN do
        table.insert(lines, full:sub(1, MAX_MSG_LEN))
        full = string.format(L["ANNOUNCE_LINE"], record.name, full:sub(MAX_MSG_LEN + 1))
    end
    table.insert(lines, full)

    return lines
end

-- ── Public API ────────────────────────────────────────────────────────────────

-- Whisper all players who have gear issues.
function BC.WhisperAll()
    local players = D.GetAllPlayers()
    local count   = 0

    for key, record in pairs(players) do
        local msg = BC.BuildWhisperMessage(record)
        if msg then
            QueueMessage(msg, "WHISPER", record.name)
            count = count + 1
        end
    end

    if count > 0 then
        print("|cff00ccff[TRI]|r " .. string.format(L["WHISPER_SENT"], count))
    else
        print("|cff00ccff[TRI]|r " .. L["NO_ISSUES_FOUND"])
    end
end

-- Whisper one specific player by key or name.
function BC.WhisperPlayer(keyOrName)
    local record = D.GetPlayerByKey(keyOrName)
    if not record then
        -- Try by name
        for k, r in pairs(D.GetAllPlayers()) do
            if r.name == keyOrName then
                record = r
                break
            end
        end
    end

    if not record then
        print("|cff00ccff[TRI]|r Player not found: " .. tostring(keyOrName))
        return
    end

    local msg = BC.BuildWhisperMessage(record)
    if msg then
        QueueMessage(msg, "WHISPER", record.name)
        print("|cff00ccff[TRI]|r Whispered " .. record.name .. ".")
    else
        print("|cff00ccff[TRI]|r " .. record.name .. " has no gear issues.")
    end
end

-- Announce a summary of all issues to group chat.
function BC.AnnounceRaid()
    if not IsInGroup() then
        print("|cff00ccff[TRI]|r " .. L["NOT_IN_GROUP"])
        return
    end

    local players = D.GetAllPlayers()
    local lines   = {}

    -- Sort by status severity (same order as UI_Main)
    local sorted = {}
    for key, record in pairs(players) do
        table.insert(sorted, record)
    end
    local statusOrder = { missing=1, wrong=2, warn=3, ok=4, unscanned=5, offline=6, timeout=6 }
    table.sort(sorted, function(a, b)
        local ao = statusOrder[a.status] or 5
        local bo = statusOrder[b.status] or 5
        if ao ~= bo then return ao < bo end
        return (a.name or "") < (b.name or "")
    end)

    for _, record in ipairs(sorted) do
        local announceLines = BC.BuildAnnounceLines(record)
        if announceLines then
            for _, line in ipairs(announceLines) do
                table.insert(lines, line)
            end
        end
    end

    if #lines == 0 then
        print("|cff00ccff[TRI]|r " .. L["NO_ISSUES_FOUND"])
        return
    end

    -- Send header + one line per player (RAID or PARTY depending on group type)
    local channel = IsInRaid() and "RAID" or "PARTY"
    QueueMessage(L["ANNOUNCE_HEADER"], channel, nil)
    for _, line in ipairs(lines) do
        QueueMessage(line, channel, nil)
    end

    print("|cff00ccff[TRI]|r " .. L["ANNOUNCE_SENT"])
end

-- Show a confirmation dialog before announcing to group.
function BC.ConfirmAnnounce()
    if not IsInGroup() then
        print("|cff00ccff[TRI]|r " .. L["NOT_IN_GROUP"])
        return
    end

    -- Use WoW's built-in static popup
    StaticPopupDialogs["RAIDINSPECTOR_CONFIRM_ANNOUNCE"] = {
        text         = L["CONFIRM_ANNOUNCE"],
        button1      = L["YES"],
        button2      = L["NO"],
        OnAccept     = function() BC.AnnounceRaid() end,
        timeout      = 30,
        whileDead    = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("RAIDINSPECTOR_CONFIRM_ANNOUNCE")
end
