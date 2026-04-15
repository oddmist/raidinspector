-- Spec.lua — Talent tree names and spec detection via GetTalentInfo iteration
-- TBC Classic Anniversary has dual talent specialization. GetTalentInfo takes
-- a talentGroup parameter (5th arg) to select active vs inactive spec.
-- We use GetActiveSpecGroup(isInspect) to get the correct group.

RaidInspectorSpec = {}
local S = RaidInspectorSpec

-- Max talents per tree in TBC (no tree exceeds 30)
local MAX_TALENTS_PER_TAB = 30

-- Static talent tree names per class (tab 1, 2, 3)
-- Source: TBC Classic in-game talent pane order
S.TAB_NAMES = {
    WARRIOR   = { "Arms",           "Fury",          "Protection"   },
    PALADIN   = { "Holy",           "Protection",    "Retribution"  },
    HUNTER    = { "Beast Mastery",  "Marksmanship",  "Survival"     },
    ROGUE     = { "Assassination",  "Combat",        "Subtlety"     },
    PRIEST    = { "Discipline",     "Holy",          "Shadow"       },
    SHAMAN    = { "Elemental",      "Enhancement",   "Restoration"  },
    MAGE      = { "Arcane",         "Fire",          "Frost"        },
    WARLOCK   = { "Affliction",     "Demonology",    "Destruction"  },
    DRUID     = { "Balance",        "Feral Combat",  "Restoration"  },
}

-- Debug flag: /ri debugspec to toggle
S.debugMode = false

-- ── Helpers ──────────────────────────────────────────────────────────────────

-- Get the active talent group (1 or 2) for self or inspected unit.
-- Falls back to 1 if the API function doesn't exist.
local _GetActiveTalentGroup = GetActiveTalentGroup  -- save global before shadowing

local function GetActiveGroup(isInspect)
    if GetActiveSpecGroup then
        return GetActiveSpecGroup(isInspect) or 1
    elseif _GetActiveTalentGroup then
        return _GetActiveTalentGroup(isInspect) or 1
    end
    return 1
end

local function PickBestTab(tabPoints)
    local bestTab = 1
    local bestPoints = 0
    for tab = 1, 3 do
        if tabPoints[tab] > bestPoints then
            bestTab = tab
            bestPoints = tabPoints[tab]
        end
    end
    return bestTab, bestPoints
end

local function DebugPrint(label, tabPoints, totalAll)
    if not S.debugMode then return end
    print(string.format("|cff00ccff[TRI Debug]|r %s: tab1=%d tab2=%d tab3=%d total=%d",
        label, tabPoints[1] or 0, tabPoints[2] or 0, tabPoints[3] or 0, totalAll))
end

-- ── Self detection ───────────────────────────────────────────────────────────
-- GetTalentInfo(tab, i, false, false, group) with explicit active talent group.

function S.DetectSelf(class)
    if not class or not S.TAB_NAMES[class] then
        return { tab=0, name="???", points=0 }
    end

    local group = GetActiveGroup(false)
    if S.debugMode then
        print("|cff00ccff[TRI Debug]|r Self activeGroup=" .. tostring(group))
    end

    local tabPoints = {}
    local totalAll = 0
    for tab = 1, 3 do
        local points = 0
        local n = GetNumTalents(tab, false) or 0
        for i = 1, n do
            local _, _, _, _, rank = GetTalentInfo(tab, i, false, false, group)
            points = points + (tonumber(rank) or 0)
        end
        tabPoints[tab] = points
        totalAll = totalAll + points
    end

    DebugPrint("Self", tabPoints, totalAll)

    local bestTab, bestPoints = PickBestTab(tabPoints)
    return {
        tab    = bestTab,
        name   = S.TAB_NAMES[class][bestTab] or "???",
        points = bestPoints,
    }
end

-- ── Inspect detection ────────────────────────────────────────────────────────
-- GetNumTalents(tab, true) returns 0 for some tabs in inspect mode, so we
-- bypass it and iterate up to a fixed limit per tab. We pass the inspected
-- unit's active talent group to read their current spec, not their inactive one.

function S.DetectFromInspect(class)
    if not class or not S.TAB_NAMES[class] then
        return { tab=0, name="???", points=0 }
    end

    local group = GetActiveGroup(true)
    if S.debugMode then
        print("|cff00ccff[TRI Debug]|r Inspect activeGroup=" .. tostring(group))
    end

    local tabPoints = {}
    local totalAll = 0
    for tab = 1, 3 do
        local points = 0
        for i = 1, MAX_TALENTS_PER_TAB do
            local name, _, _, _, rank = GetTalentInfo(tab, i, true, false, group)
            if not name then break end
            points = points + (tonumber(rank) or 0)
        end
        tabPoints[tab] = points
        totalAll = totalAll + points
    end

    DebugPrint("Inspect", tabPoints, totalAll)

    local bestTab, bestPoints = PickBestTab(tabPoints)
    return {
        tab    = bestTab,
        name   = S.TAB_NAMES[class][bestTab] or "???",
        points = bestPoints,
    }
end

-- ── Utility ──────────────────────────────────────────────────────────────────

function S.SpecLabel(spec)
    if not spec or spec.tab == 0 then return "???" end
    return spec.name or "???"
end
