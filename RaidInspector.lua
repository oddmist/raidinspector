-- RaidInspector.lua — Core init, event hub, slash commands
-- Loaded last so all modules are already defined.

-- RaidInspector global and On/Fire are defined in Locales.lua (first loaded).
-- This file wires up the core frame and slash commands.
local RI = RaidInspector
local L  = RaidInspectorL

-- ── Core frame (single event sink) ───────────────────────────────────────────

local coreFrame = CreateFrame("Frame", "RaidInspectorCoreFrame")
coreFrame:RegisterEvent("ADDON_LOADED")
coreFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
coreFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
coreFrame:RegisterEvent("INSPECT_READY")

coreFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "RaidInspector" then
            RI.OnLoad()
        end

    elseif event == "INSPECT_READY" then
        -- Pass the GUID argument through to Inspect module
        RaidInspectorInspect.OnInspectReady(...)

    elseif event == "GROUP_ROSTER_UPDATE" then
        RI.OnRosterUpdate()

    elseif event == "PLAYER_ENTERING_WORLD" then
        RI.OnEnteringWorld()
    end
end)

-- ── Initialization ────────────────────────────────────────────────────────────

function RI.OnLoad()
    -- Initialize SavedVariables with defaults
    RaidInspectorDB = RaidInspectorDB or {}
    RaidInspectorData.Init()

    -- Register slash commands
    SLASH_RAIDINSPECTOR1 = "/ri"
    SlashCmdList["RAIDINSPECTOR"] = RI.SlashHandler

    print("|cff00ccff[TRI]|r loaded. Type /ri to open.")
end

function RI.OnEnteringWorld()
    -- Nothing needed here currently; hook point for future use
end

function RI.OnRosterUpdate()
    -- If a scan is running and the roster changed, the scan will naturally
    -- handle unit token mismatches via GUID validation. No action needed.
    RI.Fire("ROSTER_UPDATED")
end

-- ── Slash command handler ─────────────────────────────────────────────────────

function RI.SlashHandler(msg)
    msg = msg and msg:lower():match("^%s*(.-)%s*$") or ""

    if msg == "" then
        RaidInspectorUI.ToggleMain()

    elseif msg == "scan" then
        if not IsInGroup() then
            print("|cff00ccff[TRI]|r " .. L["NOT_IN_GROUP"])
            return
        end
        RaidInspectorUI.ShowMain()
        RaidInspectorInspect.StartScan()

    elseif msg == "stop" then
        RaidInspectorInspect.StopScan()
        print("|cff00ccff[TRI]|r " .. L["SCAN_STOPPED"])

    elseif msg == "reset" then
        RaidInspectorInspect.StopScan()
        RaidInspectorData.ClearAll()
        RI.Fire("DATA_CLEARED")
        print("|cff00ccff[TRI]|r " .. L["DATA_CLEARED"])

    elseif msg:sub(1,5) == "show " then
        local name = msg:sub(6)
        if name ~= "" then
            RaidInspectorUI.ShowMain()
            RaidInspectorUIDetail.ShowPlayer(name)
        end

    elseif msg == "whisper" then
        RaidInspectorBroadcast.WhisperAll()

    elseif msg:sub(1,8) == "whisper " then
        local name = msg:sub(9)
        if name ~= "" then
            RaidInspectorBroadcast.WhisperPlayer(name)
        end

    elseif msg == "announce" then
        RaidInspectorBroadcast.ConfirmAnnounce()

    elseif msg == "editor" then
        RaidInspectorUIEditor.Toggle()

    elseif msg == "target" then
        RaidInspectorUI.ShowMain()
        RaidInspectorInspect.InspectTarget()

    elseif msg == "debugspec" then
        RaidInspectorSpec.debugMode = not RaidInspectorSpec.debugMode
        print("|cff00ccff[TRI]|r Spec debug: " .. (RaidInspectorSpec.debugMode and "ON" or "OFF"))

    else
        print("|cff00ccff[TRI]|r commands: /ri · /ri scan · /ri stop · /ri reset · /ri show <name> · /ri target · /ri whisper [name] · /ri announce · /ri editor")
    end
end
