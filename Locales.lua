-- Locales.lua — All user-visible strings + global pub/sub hub
-- Loaded first so all other modules can call RaidInspector.On() at load time.

-- ── Global pub/sub hub ────────────────────────────────────────────────────────
-- Defined here (first loaded file) so UI_Main/UI_Detail can register listeners
-- at module load time, before RaidInspector.lua runs its full initialization.

RaidInspector = RaidInspector or {}

local listeners = {}

function RaidInspector.On(event, fn)
    listeners[event] = listeners[event] or {}
    table.insert(listeners[event], fn)
end

function RaidInspector.Fire(event, ...)
    if not listeners[event] then return end
    for _, fn in ipairs(listeners[event]) do
        fn(...)
    end
end

-- ── String constants ──────────────────────────────────────────────────────────

local L = {}
RaidInspectorL = L

L["ADDON_NAME"]         = "Ter\195\164s Raid Inspector"
L["SCAN"]               = "Scan"
L["STOP"]               = "Stop"
L["RESET"]              = "Reset"
L["TARGET"]             = "Target"
L["RESCAN"]             = "Rescan"
L["CLOSE"]              = "Close"
L["ISSUES_ONLY"]        = "Issues Only"
L["SWEAT_MODE"]         = "Sweat Mode"
L["SCANNING"]           = "Scanning %d/%d"
L["SCAN_COMPLETE"]      = "Scan complete — %d/%d players"
L["NOT_IN_RAID"]        = "You must be in a raid to scan."
L["NOT_IN_GROUP"]       = "You must be in a group to scan."
L["SCAN_STOPPED"]       = "Scan stopped."
L["DATA_CLEARED"]       = "All data cleared."

-- Column headers
L["COL_NAME"]           = "Name"
L["COL_CLASS_SPEC"]     = "Class / Spec"
L["COL_STATUS"]         = "Status"
L["COL_ISSUES"]         = "Issues"
L["COL_SLOT"]           = "Slot"
L["COL_ITEM"]           = "Item"
L["COL_ACTUAL"]         = "Actual"
L["COL_RECOMMENDED"]    = "Recommended"
L["COL_GEMS"]           = "Gems"

-- Status labels
L["STATUS_OK"]          = "OK"
L["STATUS_MISSING"]     = "Missing"
L["STATUS_WRONG"]       = "Wrong"
L["STATUS_WARN"]        = "Warn"
L["STATUS_UNSCANNED"]   = "—"
L["STATUS_OFFLINE"]     = "Offline"
L["STATUS_TIMEOUT"]     = "Timeout"

-- Detail panel
L["DETAIL_TITLE"]       = "%s — %s / %s (%d pts)"
L["DETAIL_SPEC_UNKNOWN"]= "%s — %s / ??? (unscanned)"
L["ENCHANT_MISSING"]    = "MISSING"
L["ENCHANT_NONE_REQ"]   = "—"
L["SCAN_FOR_REC"]       = "Scan first"
L["GEMS_SUMMARY"]       = "Gems"

-- Summary in main list
L["MISSING_ENC"]        = "Missing enchants: %d"
L["MISSING_GEMS"]       = "Missing gems: %d"
L["WRONG_ENC"]          = "Bad enchants: %d"
L["LOW_QUALITY_GEMS"]   = "Low quality gems: %d"
L["OFFLINE"]            = "Offline"
L["TIMEOUT"]            = "Timeout"

-- Slot names
L["SLOT_1"]             = "Head"
L["SLOT_2"]             = "Neck"
L["SLOT_3"]             = "Shoulders"
L["SLOT_4"]             = "Shirt"
L["SLOT_5"]             = "Chest"
L["SLOT_6"]             = "Waist"
L["SLOT_7"]             = "Legs"
L["SLOT_8"]             = "Feet"
L["SLOT_9"]             = "Wrists"
L["SLOT_10"]            = "Hands"
L["SLOT_11"]            = "Finger 1"
L["SLOT_12"]            = "Finger 2"
L["SLOT_13"]            = "Trinket 1"
L["SLOT_14"]            = "Trinket 2"
L["SLOT_15"]            = "Back"
L["SLOT_16"]            = "Main Hand"
L["SLOT_17"]            = "Off Hand"
L["SLOT_18"]            = "Ranged"
L["SLOT_19"]            = "Tabard"

-- Gem detail
L["NO_SOCKETS"]         = "No sockets found"

-- Editor
L["EDITOR"]              = "Editor"
L["EDITOR_TITLE"]        = "Enchant Editor"
L["SELECT_CLASS"]        = "Select Class"
L["SELECT_SPEC"]         = "Select Spec"
L["CONTEXT_ADD_REC"]     = "Add \"%s\" to recommended"
L["ADD"]                 = "Add"
L["REMOVE"]              = "Remove"
L["ENCHANT_ID"]          = "Enchant ID"
L["NO_OVERRIDES"]        = "No custom overrides"
L["OVERRIDE_ADDED"]      = "Added enchant %s to recommended for %s %s %s."
L["HARDCODED"]           = "Default"
L["CUSTOM"]              = "Custom"

-- Import/Export
L["IMPORT"]              = "Import"
L["EXPORT"]              = "Export"
L["IMPORT_EXPORT"]       = "Import / Export"
L["IMPORT_SUCCESS"]      = "Imported %d enchant overrides."
L["IMPORT_FAILED"]       = "Import failed: invalid data."
L["EXPORT_INSTRUCTIONS"] = "Copy the text below (Ctrl+A, Ctrl+C):"
L["IMPORT_INSTRUCTIONS"] = "Paste import string below and click Import:"

-- Gem quality
L["GEM_MISSING"]         = "Empty"
L["GEM_LOW_QUALITY"]     = "Low quality gem"

-- Broadcast
L["WHISPER"]            = "Whisper"
L["ANNOUNCE"]           = "Announce"
L["WHISPER_SENT"]       = "Whispered %d players about gear issues."
L["ANNOUNCE_SENT"]      = "Announced gear check results to raid."
L["NO_ISSUES_FOUND"]    = "No gear issues found."
L["CONFIRM_ANNOUNCE"]   = "Post gear check results to raid chat?"
L["YES"]                = "Yes"
L["NO"]                 = "No"
L["WHISPER_PREFIX"]     = "[TRI]"
L["ANNOUNCE_HEADER"]    = "[TRI] Gear check results:"
L["ANNOUNCE_LINE"]      = "[TRI] %s: %s"
L["MSG_MISSING_ENC"]    = "Missing enchants: %s"
L["MSG_MISSING_GEMS"]   = "Missing gems: %s"
L["MSG_WRONG_ENC"]      = "Wrong enchants: %s"
L["MSG_LOW_GEMS"]       = "Low quality gems: %s"
L["MSG_GEM_DETAIL"]     = "%s (%d/%d)"
