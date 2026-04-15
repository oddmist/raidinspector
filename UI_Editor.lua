-- UI_Editor.lua — Enchant override editor: class/spec dropdowns, slot list, add/remove

RaidInspectorUIEditor = {}
local E   = RaidInspectorUIEditor
local U   = RaidInspectorUIUtil
local L   = RaidInspectorL
local B   = RaidInspectorBiS
local S   = RaidInspectorSpec

local WINDOW_W  = 560
local WINDOW_H  = 460
local ROW_H     = 22
local PADDING   = 10

-- Enchantable slots (slotId → display order)
local ENCHANTABLE_SLOTS = { 1, 3, 5, 7, 8, 9, 10, 15, 16, 17, 18 }

local editorFrame   = nil
local scrollFrame   = nil
local contentFrame  = nil
local rowFrames     = {}
local classDropdown = nil
local specDropdown  = nil
local selectedClass = nil
local selectedSpec  = nil   -- specTab (1, 2, or 3)

-- Ordered class list for dropdown
local CLASS_LIST = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}

local CLASS_DISPLAY = {
    WARRIOR="Warrior", PALADIN="Paladin", HUNTER="Hunter", ROGUE="Rogue",
    PRIEST="Priest", SHAMAN="Shaman", MAGE="Mage", WARLOCK="Warlock", DRUID="Druid",
}

-- ── Row population ───────────────────────────────────────────────────────────

local function RebuildRows()
    if not editorFrame or not selectedClass or not selectedSpec then return end

    -- Hide all rows first
    for i = 1, #rowFrames do
        rowFrames[i]:Hide()
    end

    local rowIdx = 0
    for _, slotId in ipairs(ENCHANTABLE_SLOTS) do
        rowIdx = rowIdx + 1
        local row = rowFrames[rowIdx]
        if not row then break end

        row:Show()
        row.slotId = slotId

        -- Slot name
        row.slotText:SetText(U.SlotName(slotId))

        -- Hardcoded enchants
        local classTbl = B.ENCHANTS[selectedClass]
        local hardcoded = nil
        if classTbl then
            local specTbl = classTbl[selectedSpec]
            if specTbl then hardcoded = specTbl[slotId] end
        end

        if hardcoded then
            row.hardcodedText:SetText(hardcoded.name)
            row.hardcodedText:SetTextColor(0.6, 0.6, 0.6)
        else
            row.hardcodedText:SetText("--")
            row.hardcodedText:SetTextColor(0.4, 0.4, 0.4)
        end

        -- Override enchants
        local override = B.GetOverridesForSlot(selectedClass, selectedSpec, slotId)
        if override and override.name then
            row.overrideText:SetText(override.name)
            row.overrideText:SetTextColor(0.3, 1, 0.3)
        else
            row.overrideText:SetText(L["NO_OVERRIDES"])
            row.overrideText:SetTextColor(0.4, 0.4, 0.4)
        end

        -- Show/hide remove button based on override existence
        if override and #override.ids > 0 then
            row.removeBtn:Show()
        else
            row.removeBtn:Hide()
        end
    end

    -- Hide remaining rows
    for i = rowIdx + 1, #rowFrames do
        rowFrames[i]:Hide()
    end

    contentFrame:SetHeight(math.max(rowIdx * ROW_H, ROW_H))
end

-- ── Add enchant popup ────────────────────────────────────────────────────────

local addFrame = nil

local function ShowAddPopup(slotId)
    if not addFrame then
        addFrame = CreateFrame("Frame", "RIEditorAddFrame", UIParent, "BackdropTemplate")
        addFrame:SetSize(260, 100)
        addFrame:SetMovable(true)
        addFrame:EnableMouse(true)
        addFrame:RegisterForDrag("LeftButton")
        addFrame:SetScript("OnDragStart", addFrame.StartMoving)
        addFrame:SetScript("OnDragStop", addFrame.StopMovingOrSizing)
        addFrame:SetClampedToScreen(true)
        addFrame:SetFrameStrata("DIALOG")
        U.SetBasicBackdrop(addFrame)

        local title = addFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", addFrame, "TOPLEFT", PADDING, -PADDING)
        title:SetText(L["ENCHANT_ID"])
        addFrame.titleText = title

        local editBox = CreateFrame("EditBox", nil, addFrame, "InputBoxTemplate")
        editBox:SetSize(130, 20)
        editBox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 4, -4)
        editBox:SetAutoFocus(false)
        editBox:SetNumeric(true)
        addFrame.editBox = editBox

        local addBtn = CreateFrame("Button", nil, addFrame, "UIPanelButtonTemplate")
        addBtn:SetSize(50, 22)
        addBtn:SetPoint("LEFT", editBox, "RIGHT", 8, 0)
        addBtn:SetText(L["ADD"])
        addFrame.addBtn = addBtn

        local closeBtn = CreateFrame("Button", nil, addFrame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", addFrame, "TOPRIGHT", -2, -2)
        closeBtn:SetScript("OnClick", function() addFrame:Hide() end)
    end

    addFrame.editBox:SetText("")
    addFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

    addFrame.addBtn:SetScript("OnClick", function()
        local idStr = addFrame.editBox:GetText()
        local enchantId = tonumber(idStr)
        if not enchantId or enchantId <= 0 then return end

        local name = B.GetEnchantName(enchantId) or ("Enchant #" .. enchantId)
        B.AddEnchantOverride(selectedClass, selectedSpec, slotId, enchantId, name)

        local L = RaidInspectorL
        print("|cff00ccff[TRI]|r " .. string.format(L["OVERRIDE_ADDED"],
            enchantId,
            CLASS_DISPLAY[selectedClass] or selectedClass,
            S.TAB_NAMES[selectedClass] and S.TAB_NAMES[selectedClass][selectedSpec] or "?",
            U.SlotName(slotId)))

        addFrame:Hide()
        RebuildRows()
        RaidInspector.Fire("SCAN_UPDATED")
    end)

    addFrame:Show()
    addFrame.editBox:SetFocus()
end

-- ── Remove last override from slot ───────────────────────────────────────────

local function RemoveOverride(slotId)
    local override = B.GetOverridesForSlot(selectedClass, selectedSpec, slotId)
    if not override or #override.ids == 0 then return end

    -- Remove the last added enchant ID
    local lastId = override.ids[#override.ids]
    B.RemoveEnchantOverride(selectedClass, selectedSpec, slotId, lastId)
    RebuildRows()
    RaidInspector.Fire("SCAN_UPDATED")
end

-- ── Build editor window ──────────────────────────────────────────────────────

local function BuildEditorWindow()
    editorFrame = CreateFrame("Frame", "RaidInspectorEditorFrame", UIParent, "BackdropTemplate")
    editorFrame:SetSize(WINDOW_W, WINDOW_H)
    editorFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    editorFrame:SetMovable(true)
    editorFrame:EnableMouse(true)
    editorFrame:RegisterForDrag("LeftButton")
    editorFrame:SetScript("OnDragStart", editorFrame.StartMoving)
    editorFrame:SetScript("OnDragStop", editorFrame.StopMovingOrSizing)
    editorFrame:SetClampedToScreen(true)
    editorFrame:Hide()
    editorFrame:SetFrameStrata("HIGH")
    U.SetBasicBackdrop(editorFrame)

    -- Title
    local title = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOPLEFT", editorFrame, "TOPLEFT", PADDING + 4, -PADDING)
    title:SetText(L["EDITOR_TITLE"])

    -- Close button
    local closeBtn = CreateFrame("Button", nil, editorFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", editorFrame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() editorFrame:Hide() end)

    -- ── Row 2: Class + Spec dropdowns + Import/Export ────────────────────────
    local row2Y = -32

    -- Class dropdown
    classDropdown = CreateFrame("Frame", "RIEditorClassDropdown", editorFrame, "UIDropDownMenuTemplate")
    classDropdown:SetPoint("TOPLEFT", editorFrame, "TOPLEFT", PADDING - 16, row2Y)

    UIDropDownMenu_SetWidth(classDropdown, 110)
    UIDropDownMenu_SetText(classDropdown, L["SELECT_CLASS"])

    UIDropDownMenu_Initialize(classDropdown, function(self, level)
        for _, class in ipairs(CLASS_LIST) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = CLASS_DISPLAY[class]
            info.arg1 = class
            info.func = function(_, arg1)
                selectedClass = arg1
                selectedSpec = nil
                UIDropDownMenu_SetText(classDropdown, CLASS_DISPLAY[arg1])
                UIDropDownMenu_SetText(specDropdown, L["SELECT_SPEC"])
                -- Reinitialize spec dropdown
                UIDropDownMenu_Initialize(specDropdown, specDropdown.initFunc)
                RebuildRows()
            end
            info.checked = (selectedClass == class)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Spec dropdown
    specDropdown = CreateFrame("Frame", "RIEditorSpecDropdown", editorFrame, "UIDropDownMenuTemplate")
    specDropdown:SetPoint("LEFT", classDropdown, "RIGHT", -10, 0)

    UIDropDownMenu_SetWidth(specDropdown, 120)
    UIDropDownMenu_SetText(specDropdown, L["SELECT_SPEC"])

    specDropdown.initFunc = function(self, level)
        if not selectedClass or not S.TAB_NAMES[selectedClass] then return end
        for tab = 1, 3 do
            local specName = S.TAB_NAMES[selectedClass][tab]
            if specName then
                local info = UIDropDownMenu_CreateInfo()
                info.text = specName
                info.arg1 = tab
                info.func = function(_, arg1)
                    selectedSpec = arg1
                    UIDropDownMenu_SetText(specDropdown, S.TAB_NAMES[selectedClass][arg1])
                    RebuildRows()
                end
                info.checked = (selectedSpec == tab)
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end

    UIDropDownMenu_Initialize(specDropdown, specDropdown.initFunc)

    -- Import/Export button (right side)
    local ieBtn = CreateFrame("Button", nil, editorFrame, "UIPanelButtonTemplate")
    ieBtn:SetSize(90, 22)
    ieBtn:SetPoint("TOPRIGHT", editorFrame, "TOPRIGHT", -PADDING, row2Y)
    ieBtn:SetText(L["IMPORT_EXPORT"])
    ieBtn:SetScript("OnClick", function()
        RaidInspectorUIImportExport.Toggle()
    end)

    -- ── Column headers ───────────────────────────────────────────────────────
    local headerY = -64
    local COL_SLOT      = PADDING
    local COL_HARDCODED = 80
    local COL_OVERRIDE  = 280
    local COL_BUTTONS   = 470

    local headers = {
        { text=L["COL_SLOT"],  x=COL_SLOT },
        { text=L["HARDCODED"], x=COL_HARDCODED },
        { text=L["CUSTOM"],    x=COL_OVERRIDE },
    }
    for _, h in ipairs(headers) do
        local fs = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", editorFrame, "TOPLEFT", h.x, headerY)
        fs:SetText(h.text)
        fs:SetTextColor(0.85, 0.85, 0.65)
    end

    -- Divider
    local div = editorFrame:CreateTexture(nil, "ARTWORK")
    div:SetPoint("TOPLEFT",  editorFrame, "TOPLEFT",  PADDING, -78)
    div:SetPoint("TOPRIGHT", editorFrame, "TOPRIGHT", -PADDING, -78)
    div:SetHeight(1)
    U.SetSolidColor(div, 0.4, 0.4, 0.5, 0.3)

    -- ── Scroll frame ─────────────────────────────────────────────────────────
    scrollFrame = CreateFrame("ScrollFrame", "RIEditorScrollFrame", editorFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",     editorFrame, "TOPLEFT",     PADDING,  -82)
    scrollFrame:SetPoint("BOTTOMRIGHT", editorFrame, "BOTTOMRIGHT", -28,      PADDING)

    contentFrame = CreateFrame("Frame", "RIEditorContentFrame", scrollFrame)
    contentFrame:SetSize(WINDOW_W - 40, ROW_H * #ENCHANTABLE_SLOTS)
    scrollFrame:SetScrollChild(contentFrame)

    -- ── Pre-create row frames ────────────────────────────────────────────────
    for i = 1, #ENCHANTABLE_SLOTS do
        local row = CreateFrame("Frame", nil, contentFrame)
        row:SetHeight(ROW_H)
        row:SetPoint("TOPLEFT",  contentFrame, "TOPLEFT",  0,       -(i-1) * ROW_H)
        row:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", -PADDING, -(i-1) * ROW_H)

        U.AddRowStripe(row, i)

        -- Slot name
        local slotText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        slotText:SetPoint("LEFT", row, "LEFT", 0, 0)
        slotText:SetWidth(70)
        slotText:SetJustifyH("LEFT")
        row.slotText = slotText

        -- Hardcoded enchants
        local hardcodedText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hardcodedText:SetPoint("LEFT", row, "LEFT", COL_HARDCODED - PADDING, 0)
        hardcodedText:SetWidth(190)
        hardcodedText:SetJustifyH("LEFT")
        row.hardcodedText = hardcodedText

        -- Override enchants
        local overrideText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        overrideText:SetPoint("LEFT", row, "LEFT", COL_OVERRIDE - PADDING, 0)
        overrideText:SetWidth(180)
        overrideText:SetJustifyH("LEFT")
        row.overrideText = overrideText

        -- Add button [+]
        local addBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        addBtn:SetSize(22, 18)
        addBtn:SetPoint("LEFT", row, "LEFT", COL_BUTTONS - PADDING, 0)
        addBtn:SetText("+")
        addBtn:SetScript("OnClick", function()
            if selectedClass and selectedSpec then
                ShowAddPopup(row.slotId)
            end
        end)

        -- Remove button [-]
        local removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        removeBtn:SetSize(22, 18)
        removeBtn:SetPoint("LEFT", addBtn, "RIGHT", 2, 0)
        removeBtn:SetText("-")
        removeBtn:SetScript("OnClick", function()
            if selectedClass and selectedSpec then
                RemoveOverride(row.slotId)
            end
        end)
        row.removeBtn = removeBtn

        row:Hide()
        rowFrames[i] = row
    end
end

-- ── Public API ───────────────────────────────────────────────────────────────

function E.Toggle()
    if not editorFrame then BuildEditorWindow() end
    if editorFrame:IsShown() then
        editorFrame:Hide()
    else
        editorFrame:Show()
        RebuildRows()
    end
end

function E.Show()
    if not editorFrame then BuildEditorWindow() end
    editorFrame:Show()
    RebuildRows()
end

function E.Hide()
    if editorFrame then editorFrame:Hide() end
end
