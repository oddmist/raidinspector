-- Data.lua — Data model, SavedVars schema, item link parsing, player records
-- Owns RaidInspectorDB and all read/write operations on it.

RaidInspectorData = {}
local D = RaidInspectorData

-- Slot IDs we track (excludes shirt=4, tabard=19, neck=2, rings=11/12, trinkets=13/14
-- for enchant purposes, but we still store item data for ALL slots for display)
D.ALL_SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }

local DB_VERSION = 2

-- ── Initialization ────────────────────────────────────────────────────────────

function D.Init()
    RaidInspectorDB = RaidInspectorDB or {}
    local db = RaidInspectorDB

    if (db.version or 0) < 2 and (db.version or 0) >= 1 then
        -- Migrate v1 → v2: add enchantOverrides, keep player data
        db.enchantOverrides = {}
        db.version = DB_VERSION
    elseif (db.version or 0) < 1 then
        -- Fresh install or incompatible old version
        db.players  = {}
        db.lastScan = 0
        db.enchantOverrides = {}
        db.version  = DB_VERSION
    end

    db.players          = db.players          or {}
    db.lastScan         = db.lastScan         or 0
    db.enchantOverrides = db.enchantOverrides  or {}
    if db.sweatMode == nil then db.sweatMode = false end
end

-- ── Key helpers ───────────────────────────────────────────────────────────────

local function PlayerKey(name, realm)
    if realm and realm ~= "" then
        return name .. "-" .. realm
    end
    return name
end

-- ── Item link parser ──────────────────────────────────────────────────────────
-- TBC item link format:
--   |Hitem:itemID:enchantID:gem1:gem2:gem3:gem4:suffixID:uniqueID:...|h[Name]|h|r

function D.ParseItemLink(link)
    if not link then return nil end

    -- TBC Anniversary uses retail-style item links where empty fields may be
    -- blank (::) instead of (:0:).  Use %d* to accept empty strings, then
    -- default to 0.
    local itemId, enchantId, gem1, gem2, gem3, gem4 =
        link:match("|Hitem:(%d+):(%d*):(%d*):(%d*):(%d*):(%d*):")

    if not itemId then return nil end

    -- GetItemInfo may return nil if item is not yet cached; caller handles retries
    local name, _, quality, _, _, _, _, _, equipLoc = GetItemInfo(link)

    return {
        itemLink   = link,
        itemId     = tonumber(itemId),
        itemName   = name or ("Item:" .. itemId),
        quality    = quality or 1,
        equipLoc   = equipLoc or "",
        enchantId  = tonumber(enchantId) or 0,
        gems       = {
            tonumber(gem1) or 0,
            tonumber(gem2) or 0,
            tonumber(gem3) or 0,
            tonumber(gem4) or 0,
        },
        -- These are filled in by HarvestInspectData after Rules checks:
        gemSlotsExpected = 0,
        gemsFilled       = 0,
        gemQualities     = {},
        enchantMissing   = false,
        enchantWrong     = false,
        gemsMissing      = false,
        gemsLowQuality   = false,
    }
end

-- ── Harvest self ──────────────────────────────────────────────────────────────
-- Read our own gear and spec without NotifyInspect.

function D.HarvestSelf()
    local name   = UnitName("player")
    if not name then return end  -- guard: can be nil during logout/loading screen
    local realm  = GetRealmName()
    local _, class = UnitClass("player")
    local level  = UnitLevel("player")

    local record = D.BuildRecord(name, realm, class, level)

    -- Detect spec FIRST so FillSlotFlags can use it for BiS comparisons
    record.spec = RaidInspectorSpec.DetectSelf(class)

    for _, slotId in ipairs(D.ALL_SLOTS) do
        local link = GetInventoryItemLink("player", slotId)
        if link then
            local slotData = D.ParseItemLinkWithRetry(link)
            if slotData then
                D.FillSlotFlags(slotData, slotId, class, record.spec)
                record.slots[slotId] = slotData
            end
        end
    end

    D.ComputeAggregates(record)
    RaidInspectorDB.players[PlayerKey(name, realm)] = record
end

-- ── Harvest inspected unit ────────────────────────────────────────────────────
-- Called synchronously inside INSPECT_READY. Returns the stored record.

function D.HarvestInspectData(unit)
    local name, realm = UnitName(unit)
    if not name then return nil end

    local _, class = UnitClass(unit)
    local level    = UnitLevel(unit)
    local spec     = RaidInspectorSpec.DetectFromInspect(class)

    local record = D.BuildRecord(name, realm, class, level)
    record.spec  = spec

    for _, slotId in ipairs(D.ALL_SLOTS) do
        local link = GetInventoryItemLink(unit, slotId)
        if link then
            local slotData = D.ParseItemLinkWithRetry(link)
            if slotData then
                D.FillSlotFlags(slotData, slotId, class, spec)
                record.slots[slotId] = slotData
            end
        end
    end

    D.ComputeAggregates(record)

    local key = PlayerKey(name, realm)
    RaidInspectorDB.players[key] = record
    RaidInspectorDB.lastScan = time()

    return record
end

-- ── Internal helpers ──────────────────────────────────────────────────────────

function D.BuildRecord(name, realm, class, level)
    return {
        name    = name,
        realm   = realm or "",
        class   = class or "UNKNOWN",
        level   = level or 0,
        scannedAt = time(),
        spec    = { tab=0, name="???", points=0 },
        slots   = {},
        missingEnchants = 0,
        wrongEnchants   = 0,
        missingGems     = 0,
        lowQualityGems  = 0,
        status  = "ok",
    }
end

-- Parse item link once. GetItemInfo is async — if the item isn't cached yet the
-- name will fall back to "Item:NNNNN". The item link itself is always stored and
-- the UI can call GetItemInfo later for display purposes.
function D.ParseItemLinkWithRetry(link)
    return D.ParseItemLink(link)
end

-- Fill enchantMissing, enchantWrong, gemSlotsExpected, gemsFilled, gemsMissing
function D.FillSlotFlags(slotData, slotId, class, spec)
    -- Enchant flags
    local enchantRequired = RaidInspectorRules.IsEnchantRequired(slotId, slotData, class)
    if enchantRequired then
        if slotData.enchantId == 0 then
            slotData.enchantMissing = true
        else
            -- Has enchant — check if it is recommended for this spec
            local specTab = spec and spec.tab or 0
            local rec = RaidInspectorBiS.IsRecommendedEnchant(class, specTab, slotId, slotData.enchantId)
            -- rec: true = good, false = wrong, nil = no opinion
            if rec == false then
                slotData.enchantWrong = true
            end
        end
    end

    -- Gem socket flags
    local expected = RaidInspectorRules.GetExpectedGemCount(slotData.itemLink)
    slotData.gemSlotsExpected = expected

    local filled = 0
    slotData.gemQualities = {}
    for idx, gemId in ipairs(slotData.gems) do
        if gemId and gemId ~= 0 then
            filled = filled + 1
            local _, _, quality = GetItemInfo(gemId)
            slotData.gemQualities[idx] = quality or 0
        else
            slotData.gemQualities[idx] = 0
        end
    end
    slotData.gemsFilled  = filled
    slotData.gemsMissing = (filled < expected)

    -- Flag low-quality gems (green = quality 2)
    slotData.gemsLowQuality = false
    for idx = 1, 4 do
        if slotData.gemQualities[idx] == 2 and slotData.gems[idx] ~= 0 then
            slotData.gemsLowQuality = true
            break
        end
    end
end

-- Recompute per-player aggregate counts and status
function D.ComputeAggregates(record)
    local missingEnchants = 0
    local wrongEnchants   = 0
    local missingGems     = 0
    local lowQualityGems  = 0

    for _, slot in pairs(record.slots) do
        if slot.enchantMissing  then missingEnchants = missingEnchants + 1 end
        if slot.enchantWrong    then wrongEnchants   = wrongEnchants   + 1 end
        if slot.gemsMissing     then missingGems      = missingGems     + 1 end
        if slot.gemsLowQuality  then lowQualityGems   = lowQualityGems  + 1 end
    end

    record.missingEnchants = missingEnchants
    record.wrongEnchants   = wrongEnchants
    record.missingGems     = missingGems
    record.lowQualityGems  = lowQualityGems

    if missingEnchants > 0 then
        record.status = "missing"
    elseif wrongEnchants > 0 then
        record.status = "wrong"
    elseif missingGems > 0 or lowQualityGems > 0 then
        record.status = "warn"
    else
        record.status = "ok"
    end
end

-- ── Public read API ───────────────────────────────────────────────────────────

function D.GetPlayer(name, realm)
    return RaidInspectorDB.players[PlayerKey(name, realm)]
end

function D.GetPlayerByKey(key)
    return RaidInspectorDB.players[key]
end

function D.GetAllPlayers()
    return RaidInspectorDB.players
end

function D.StoreOffline(name, realm)
    local key = PlayerKey(name or "Unknown", realm)
    RaidInspectorDB.players[key] = {
        name    = name or "Unknown",
        realm   = realm or "",
        class   = "UNKNOWN",
        level   = 0,
        scannedAt = time(),
        spec    = { tab=0, name="???", points=0 },
        slots   = {},
        missingEnchants = 0,
        wrongEnchants   = 0,
        missingGems     = 0,
        lowQualityGems  = 0,
        status  = "offline",
    }
end

function D.StoreTimeout(name, realm)
    local key = PlayerKey(name or "Unknown", realm)
    RaidInspectorDB.players[key] = {
        name    = name or "Unknown",
        realm   = realm or "",
        class   = "UNKNOWN",
        level   = 0,
        scannedAt = time(),
        spec    = { tab=0, name="???", points=0 },
        slots   = {},
        missingEnchants = 0,
        wrongEnchants   = 0,
        missingGems     = 0,
        lowQualityGems  = 0,
        status  = "timeout",
    }
end

function D.SetSweatMode(enabled)
    if not RaidInspectorDB then return end
    RaidInspectorDB.sweatMode = enabled
    D.ReEvaluateAll()
end

function D.IsSweatMode()
    return RaidInspectorDB and RaidInspectorDB.sweatMode or false
end

-- Re-evaluate enchant flags for all stored players (after mode toggle)
function D.ReEvaluateAll()
    if not RaidInspectorDB or not RaidInspectorDB.players then return end
    for _, record in pairs(RaidInspectorDB.players) do
        if record.slots then
            for slotId, slotData in pairs(record.slots) do
                -- Reset enchant flags and recheck
                slotData.enchantMissing = false
                slotData.enchantWrong   = false
                D.FillSlotFlags(slotData, slotId, record.class, record.spec)
            end
            D.ComputeAggregates(record)
        end
    end
end

function D.ClearAll()
    RaidInspectorDB.players  = {}
    RaidInspectorDB.lastScan = 0
end

function D.PlayerCount()
    local n = 0
    for _ in pairs(RaidInspectorDB.players) do n = n + 1 end
    return n
end
