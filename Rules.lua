-- Rules.lua — Enchant slot requirements and gem socket detection
-- IsEnchantRequired: is an enchant mandatory for this slot/class?
-- GetExpectedGemCount: how many gem sockets does this item have?

RaidInspectorRules = {}
local R = RaidInspectorRules

-- ── Enchant required slots ────────────────────────────────────────────────────
-- Slots that require enchants for ALL classes (unless overridden below).

R.ENCHANT_REQUIRED_SLOTS = {
    [1]  = true,   -- Head       (Arcanum from faction rep)
    [3]  = true,   -- Shoulders  (Inscription from faction rep)
    [5]  = true,   -- Chest      (Enchant Chest)
    [7]  = true,   -- Legs       (Leg armor patches: Nethercobra, Mystic, etc.)
    [8]  = true,   -- Feet       (Enchant Boots)
    [9]  = true,   -- Wrists     (Enchant Bracer)
    [10] = true,   -- Hands      (Enchant Gloves)
    [15] = true,   -- Back       (Enchant Cloak)
    [16] = true,   -- Main Hand  (weapon enchant always expected)
    -- [17] Off Hand: conditional — see IsEnchantRequired
    -- [18] Ranged: only for hunters — see IsEnchantRequired
}

-- equipLoc values that can receive a weapon enchant
local ENCHANTABLE_OFFHAND_LOCS = {
    INVTYPE_WEAPON       = true,  -- one-hand weapon wielded in off-hand
    INVTYPE_WEAPONOFFHAND = true, -- explicit off-hand weapon type
    INVTYPE_SHIELD        = true, -- shields can have enchants (e.g. shield spike)
}

-- ── IsEnchantRequired ─────────────────────────────────────────────────────────
-- slotData: table with .enchantId, .equipLoc fields (from Data.ParseItemLink)
-- Returns true if a player should have an enchant in this slot.

function R.IsEnchantRequired(slotId, slotData, class)
    if R.ENCHANT_REQUIRED_SLOTS[slotId] then
        return true
    end

    -- Slot 17 — Off Hand: only enchantable for weapons and shields
    if slotId == 17 then
        return ENCHANTABLE_OFFHAND_LOCS[slotData.equipLoc] == true
    end

    -- Slot 18 — Ranged: only hunters are expected to have a scope
    if slotId == 18 then
        return class == "HUNTER"
    end

    return false
end

-- ── Gem socket detection ──────────────────────────────────────────────────────
-- The item link alone cannot distinguish "no sockets" from "sockets but empty"
-- (both show gem1=0 gem2=0 etc.). We use a hidden scan tooltip to count socket
-- lines, which is the only reliable approach in TBC Classic.

local scanTooltip = nil

local function EnsureScanTooltip()
    if scanTooltip then return end
    scanTooltip = CreateFrame("GameTooltip", "RaidInspectorScanTooltip", nil, "GameTooltipTemplate")
    scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
end

-- Specific socket line patterns (English client).
-- Matches "Red Socket", "Blue Socket", "Yellow Socket", "Meta Socket",
-- "Prismatic Socket" — but NOT "Socket Bonus: ..." which also contains "Socket".
local SOCKET_COLORS = {
    ["Red Socket"]       = true,
    ["Blue Socket"]      = true,
    ["Yellow Socket"]    = true,
    ["Meta Socket"]      = true,
    ["Prismatic Socket"] = true,
}

function R.GetExpectedGemCount(itemLink)
    if not itemLink then return 0 end

    EnsureScanTooltip()
    -- Re-own tooltip before each scan — ownership can be lost between calls
    scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

    local ok = pcall(function()
        scanTooltip:ClearLines()
        scanTooltip:SetHyperlink(itemLink)
    end)

    if not ok then
        return R.CountGemsInLink(itemLink)
    end

    local count = 0
    local numLines = scanTooltip:NumLines() or 0
    for i = 1, numLines do
        local leftText = _G["RaidInspectorScanTooltipTextLeft" .. i]
        if leftText then
            local txt = leftText:GetText()
            if txt and SOCKET_COLORS[txt] then
                count = count + 1
            end
        end
    end

    -- If tooltip returned nothing, fall back to counting gems in item link
    if count == 0 then
        return R.CountGemsInLink(itemLink)
    end

    return count
end

-- Fallback: count non-zero gem values in item link (undercounts empty sockets)
function R.CountGemsInLink(itemLink)
    if not itemLink then return 0 end
    local _, enchId, g1, g2, g3, g4 =
        itemLink:match("|Hitem:(%d+):(%d*):(%d*):(%d*):(%d*):(%d*):")
    if not g1 then return 0 end
    local n = 0
    for _, v in ipairs({ tonumber(g1), tonumber(g2), tonumber(g3), tonumber(g4) }) do
        if v and v ~= 0 then n = n + 1 end
    end
    return n
end
