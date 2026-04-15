-- UI_Main.lua — Main window: scrollable 40-row raid list, progress bar, filters

RaidInspectorUI = {}
local UI  = RaidInspectorUI
local U   = RaidInspectorUIUtil
local L   = RaidInspectorL

local WINDOW_W  = 840
local WINDOW_H  = 500
local ROW_H     = 24
local VISIBLE_ROWS = 18
local PADDING   = 10

-- Column X positions (left edge within content area)
local COL_NAME      = 0
local COL_CLASS     = 200
local COL_STATUS    = 360
local COL_ISSUES    = 460

-- ── Frames ────────────────────────────────────────────────────────────────────

local mainFrame      = nil
local scrollFrame    = nil
local contentFrame   = nil
local progressBar    = nil
local progressLabel  = nil
local scanBtn        = nil
local stopBtn        = nil
local resetBtn       = nil
local whisperBtn     = nil
local announceBtn    = nil
local editorBtn      = nil
local filterCheck    = nil
local rowFrames      = {}   -- pre-created row frames (pool of VISIBLE_ROWS)
local rowData        = {}   -- ordered list of {key, record} currently displayed

local filterIssuesOnly = false
local sweatCheck       = nil

-- ── Build main window ─────────────────────────────────────────────────────────

local function BuildMainWindow()
    mainFrame = CreateFrame("Frame", "RaidInspectorMainFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(WINDOW_W, WINDOW_H)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop",  mainFrame.StopMovingOrSizing)
    mainFrame:SetClampedToScreen(true)
    mainFrame:Hide()
    U.SetBasicBackdrop(mainFrame)

    -- ── Row 1: Title + Close button ──────────────────────────────────────────
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", PADDING + 4, -PADDING)
    title:SetText(L["ADDON_NAME"])

    local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() mainFrame:Hide() end)

    -- ── Row 2: Buttons + Progress bar + Filter ───────────────────────────────
    -- Layout (left to right): [Whisper][Announce][Reset] [progress bar] [Scan/Stop] [Issues Only ☐]
    local row2Y = -32

    -- Whisper / Announce (left side)
    whisperBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    whisperBtn:SetSize(72, 22)
    whisperBtn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", PADDING, row2Y)
    whisperBtn:SetText(L["WHISPER"])
    whisperBtn:SetScript("OnClick", function()
        RaidInspectorBroadcast.WhisperAll()
    end)

    announceBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    announceBtn:SetSize(76, 22)
    announceBtn:SetPoint("LEFT", whisperBtn, "RIGHT", 4, 0)
    announceBtn:SetText(L["ANNOUNCE"])
    announceBtn:SetScript("OnClick", function()
        RaidInspectorBroadcast.ConfirmAnnounce()
    end)

    resetBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    resetBtn:SetSize(60, 22)
    resetBtn:SetPoint("LEFT", announceBtn, "RIGHT", 4, 0)
    resetBtn:SetText(L["RESET"])
    resetBtn:SetScript("OnClick", function()
        if not IsInGroup() then
            print("|cff00ccff[TRI]|r " .. L["NOT_IN_GROUP"])
            return
        end
        RaidInspectorInspect.StopScan()
        RaidInspectorData.ClearAll()
        RaidInspector.Fire("DATA_CLEARED")
        RaidInspectorInspect.StartScan()
    end)

    editorBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    editorBtn:SetSize(60, 22)
    editorBtn:SetPoint("LEFT", resetBtn, "RIGHT", 4, 0)
    editorBtn:SetText(L["EDITOR"])
    editorBtn:SetScript("OnClick", function()
        RaidInspectorUIEditor.Toggle()
    end)

    -- Filter checkbox (right side)
    filterCheck = CreateFrame("CheckButton", nil, mainFrame, "UICheckButtonTemplate")
    filterCheck:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -PADDING, row2Y + 1)
    filterCheck:SetSize(20, 20)
    local filterLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    filterLabel:SetPoint("RIGHT", filterCheck, "LEFT", -2, 0)
    filterLabel:SetText(L["ISSUES_ONLY"])
    filterCheck:SetScript("OnClick", function(self)
        filterIssuesOnly = self:GetChecked()
        UI.Refresh()
    end)

    -- Sweat Mode checkbox (to the left of Issues Only)
    sweatCheck = CreateFrame("CheckButton", nil, mainFrame, "UICheckButtonTemplate")
    sweatCheck:SetSize(20, 20)
    sweatCheck:SetPoint("RIGHT", filterLabel, "LEFT", -8, 0)
    local sweatLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sweatLabel:SetPoint("RIGHT", sweatCheck, "LEFT", -2, 0)
    sweatLabel:SetText(L["SWEAT_MODE"])
    sweatCheck:SetChecked(RaidInspectorData.IsSweatMode())
    sweatCheck:SetScript("OnClick", function(self)
        RaidInspectorData.SetSweatMode(self:GetChecked())
        UI.Refresh()
    end)

    -- Scan / Stop (to the left of sweat mode)
    scanBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    scanBtn:SetSize(60, 22)
    scanBtn:SetPoint("RIGHT", sweatLabel, "LEFT", -8, 0)
    scanBtn:SetText(L["SCAN"])
    scanBtn:SetScript("OnClick", function()
        if not IsInGroup() then
            print("|cff00ccff[TRI]|r " .. L["NOT_IN_GROUP"])
            return
        end
        RaidInspectorInspect.StartScan()
    end)

    stopBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    stopBtn:SetSize(60, 22)
    stopBtn:SetPoint("RIGHT", sweatLabel, "LEFT", -8, 0)
    stopBtn:SetText(L["STOP"])
    stopBtn:Hide()
    stopBtn:SetScript("OnClick", function()
        RaidInspectorInspect.StopScan()
        stopBtn:Hide()
        scanBtn:Show()
    end)

    -- Progress bar (fills space between Editor and Scan)
    local barBg = CreateFrame("StatusBar", nil, mainFrame)
    barBg:SetPoint("LEFT",  editorBtn, "RIGHT", 8, 0)
    barBg:SetPoint("RIGHT", scanBtn,     "LEFT", -8, 0)
    barBg:SetHeight(14)
    barBg:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    barBg:SetStatusBarColor(0.2, 0.2, 0.2)
    barBg:SetMinMaxValues(0, 1)
    barBg:SetValue(0)

    progressBar = CreateFrame("StatusBar", nil, mainFrame)
    progressBar:SetAllPoints(barBg)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0.1, 0.7, 0.1)
    progressBar:SetMinMaxValues(0, 1)
    progressBar:SetValue(0)

    progressLabel = progressBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    progressLabel:SetPoint("CENTER", progressBar, "CENTER", 0, 0)
    progressLabel:SetText("")

    -- ── Row 3: Column headers ────────────────────────────────────────────────
    local headerY = -58
    local headers = {
        { text=L["COL_NAME"],       x=PADDING + COL_NAME  },
        { text=L["COL_CLASS_SPEC"], x=PADDING + COL_CLASS },
        { text=L["COL_STATUS"],     x=PADDING + COL_STATUS},
        { text=L["COL_ISSUES"],     x=PADDING + COL_ISSUES},
    }
    for _, h in ipairs(headers) do
        local fs = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", h.x, headerY)
        fs:SetText(h.text)
        fs:SetTextColor(0.85, 0.85, 0.65)
    end

    -- Divider line
    local div = mainFrame:CreateTexture(nil, "ARTWORK")
    div:SetPoint("TOPLEFT",  mainFrame, "TOPLEFT",  PADDING, -72)
    div:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -PADDING, -72)
    div:SetHeight(1)
    U.SetSolidColor(div, 0.4, 0.4, 0.5, 0.3)

    -- Scroll frame
    scrollFrame = CreateFrame("ScrollFrame", "RaidInspectorScrollFrame", mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",     mainFrame, "TOPLEFT",     PADDING,  -76)
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -28,      PADDING)

    contentFrame = CreateFrame("Frame", "RaidInspectorContentFrame", scrollFrame)
    contentFrame:SetSize(WINDOW_W - 40, ROW_H * 40)
    scrollFrame:SetScrollChild(contentFrame)

    -- Pre-create row frames
    for i = 1, 40 do
        local row = CreateFrame("Button", nil, contentFrame)
        row:SetHeight(ROW_H)
        row:SetPoint("TOPLEFT",  contentFrame, "TOPLEFT",  0,       -(i-1) * ROW_H)
        row:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", -PADDING, -(i-1) * ROW_H)

        -- Row striping
        U.AddRowStripe(row, i)

        -- Highlight on hover
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        U.SetSolidColor(hl, 1, 1, 1, 0.06)

        -- Status dot
        local dot = row:CreateTexture(nil, "ARTWORK")
        dot:SetSize(8, 8)
        dot:SetPoint("LEFT", row, "LEFT", COL_STATUS, 0)
        dot:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        dot:SetVertexColor(0.5, 0.5, 0.5)

        -- Name
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameText:SetPoint("LEFT", row, "LEFT", COL_NAME, 0)
        nameText:SetWidth(190)
        nameText:SetJustifyH("LEFT")

        -- Class/Spec
        local classText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        classText:SetPoint("LEFT", row, "LEFT", COL_CLASS, 0)
        classText:SetWidth(155)
        classText:SetJustifyH("LEFT")

        -- Issues
        local issueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        issueText:SetPoint("LEFT", row, "LEFT", COL_ISSUES, 0)
        issueText:SetWidth(220)
        issueText:SetJustifyH("LEFT")

        row.dot       = dot
        row.nameText  = nameText
        row.classText = classText
        row.issueText = issueText
        row:Hide()

        row:SetScript("OnClick", function()
            if row.playerKey then
                RaidInspectorUIDetail.ShowPlayer(row.playerKey)
            end
        end)

        rowFrames[i] = row
    end
end

-- ── Row update ────────────────────────────────────────────────────────────────

local function UpdateRow(rowIdx, key, record)
    local row = rowFrames[rowIdx]
    if not row then return end

    row.playerKey = key
    row:Show()

    local name   = record.name or key
    local class  = record.class or "UNKNOWN"
    local spec   = record.spec
    local status = record.status or "unscanned"

    -- Name (class color)
    local cc = U.ClassColor(class)
    row.nameText:SetText(name)
    row.nameText:SetTextColor(cc.r, cc.g, cc.b)

    -- Class / Spec
    local specLabel = (spec and spec.tab ~= 0) and spec.name or "???"
    local classStr  = (class ~= "UNKNOWN") and (class:sub(1,1) .. class:sub(2):lower()) or "?"
    row.classText:SetText(classStr .. " - " .. specLabel)
    row.classText:SetTextColor(cc.r, cc.g, cc.b)

    -- Status dot
    local sc = U.StatusColor(status)
    row.dot:SetVertexColor(sc.r, sc.g, sc.b)

    -- Issues summary
    local summary = U.StatusSummary(record)
    row.issueText:SetText(summary)
    local ic = U.StatusColor(status)
    row.issueText:SetTextColor(ic.r, ic.g, ic.b)
end

-- ── Refresh ───────────────────────────────────────────────────────────────────

function UI.Refresh()
    if not mainFrame or not mainFrame:IsShown() then return end

    -- Build sorted display list
    rowData = {}
    local players = RaidInspectorData.GetAllPlayers()

    for key, record in pairs(players) do
        table.insert(rowData, { key=key, record=record })
    end

    -- Sort: missing first, then wrong, then warn, then ok, then unscanned/offline
    local statusOrder = { missing=1, wrong=2, warn=3, ok=4, unscanned=5, offline=6, timeout=6 }
    table.sort(rowData, function(a, b)
        local ao = statusOrder[a.record.status] or 5
        local bo = statusOrder[b.record.status] or 5
        if ao ~= bo then return ao < bo end
        return (a.record.name or "") < (b.record.name or "")
    end)

    -- Filter
    local visible = {}
    for _, entry in ipairs(rowData) do
        if not filterIssuesOnly
            or (entry.record.status ~= "ok" and entry.record.status ~= "unscanned")
        then
            table.insert(visible, entry)
        end
    end

    -- Update row frames
    for i, entry in ipairs(visible) do
        if i <= #rowFrames then
            UpdateRow(i, entry.key, entry.record)
        end
    end
    -- Hide unused rows
    for i = #visible + 1, #rowFrames do
        rowFrames[i]:Hide()
        rowFrames[i].playerKey = nil
    end

    -- Adjust content frame height
    contentFrame:SetHeight(math.max(ROW_H * #visible, ROW_H))

    -- Update progress and button states
    local scanning = RaidInspectorInspect.IsScanning()
    if scanning then
        local done, total = RaidInspectorInspect.GetProgress()
        local pct = total > 0 and (done / total) or 0
        progressBar:SetValue(pct)
        progressLabel:SetText(string.format(L["SCANNING"], done, total))
        scanBtn:Hide()
        stopBtn:Show()
        -- Disable broadcast/reset buttons during scan
        whisperBtn:Disable()
        announceBtn:Disable()
        resetBtn:Disable()
    else
        local total = RaidInspectorData.PlayerCount()
        if total > 0 then
            progressBar:SetValue(1)
            progressLabel:SetText(string.format(L["SCAN_COMPLETE"], total, total))
        else
            progressBar:SetValue(0)
            progressLabel:SetText("")
        end
        scanBtn:Show()
        stopBtn:Hide()
        -- Enable broadcast/reset buttons when not scanning
        whisperBtn:Enable()
        announceBtn:Enable()
        resetBtn:Enable()
    end
end

-- ── Show / Hide / Toggle ──────────────────────────────────────────────────────

function UI.ShowMain()
    if not mainFrame then BuildMainWindow() end
    mainFrame:Show()
    UI.Refresh()
end

function UI.HideMain()
    if mainFrame then mainFrame:Hide() end
end

function UI.ToggleMain()
    if not mainFrame then BuildMainWindow() end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        UI.Refresh()
    end
end

-- ── Event subscriptions ───────────────────────────────────────────────────────

RaidInspector.On("SCAN_UPDATED", function()
    UI.Refresh()
end)

RaidInspector.On("SCAN_COMPLETE", function()
    UI.Refresh()
end)

RaidInspector.On("DATA_CLEARED", function()
    UI.Refresh()
end)
