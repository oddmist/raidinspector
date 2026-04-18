-- UI_Detail.lua — Per-player detail panel: all slots, Actual vs Recommended enchants/gems

RaidInspectorUIDetail = {}
local UD = RaidInspectorUIDetail
local U  = RaidInspectorUIUtil
local L  = RaidInspectorL

local DETAIL_W  = 660
local DETAIL_H  = 490
local ROW_H     = 24
local PADDING   = 10

-- Column X positions within the detail frame
local COL_SLOT   = 0
local COL_ITEM   = 80
local COL_ACTUAL = 270
local COL_REC    = 400
local COL_GEMS   = 540

-- Slot IDs to display (ordered)
local DISPLAY_SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }

-- ── Frames ────────────────────────────────────────────────────────────────────

local detailFrame  = nil
local headerText   = nil
local whisperBtn   = nil
local slotRows     = {}   -- [slotId] = { slotLabel, itemBtn, itemText, actualBtn, actualText, recText, gemsText }
local currentKey   = nil
local contextMenu  = nil  -- reusable right-click menu frame

-- ── Build detail window ───────────────────────────────────────────────────────

local function BuildDetailFrame()
    detailFrame = CreateFrame("Frame", "RaidInspectorDetailFrame", UIParent, "BackdropTemplate")
    detailFrame:SetSize(DETAIL_W, DETAIL_H)
    -- Anchor next to main window if it exists, otherwise center on screen
    local anchor = _G["RaidInspectorMainFrame"]
    if anchor then
        detailFrame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 8, 0)
    else
        detailFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    end
    detailFrame:SetMovable(true)
    detailFrame:EnableMouse(true)
    detailFrame:RegisterForDrag("LeftButton")
    detailFrame:SetScript("OnDragStart", detailFrame.StartMoving)
    detailFrame:SetScript("OnDragStop",  detailFrame.StopMovingOrSizing)
    detailFrame:SetClampedToScreen(true)
    detailFrame:Hide()
    U.SetBasicBackdrop(detailFrame)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, detailFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", detailFrame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() detailFrame:Hide() end)

    -- Whisper button (to the left of close button)
    whisperBtn = CreateFrame("Button", nil, detailFrame, "GameMenuButtonTemplate")
    whisperBtn:SetSize(70, 20)
    whisperBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
    whisperBtn:SetText(L["WHISPER"])
    whisperBtn:SetScript("OnClick", function()
        if currentKey then
            RaidInspectorBroadcast.WhisperPlayer(currentKey)
        end
    end)

    -- Header (player name / class / spec)
    headerText = detailFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    headerText:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", PADDING + 4, -PADDING)
    headerText:SetWidth(DETAIL_W - 110)
    headerText:SetJustifyH("LEFT")

    -- Divider
    local div = detailFrame:CreateTexture(nil, "ARTWORK")
    div:SetPoint("TOPLEFT",  detailFrame, "TOPLEFT",  PADDING, -34)
    div:SetPoint("TOPRIGHT", detailFrame, "TOPRIGHT", -PADDING, -34)
    div:SetHeight(1)
    U.SetSolidColor(div, 0.4, 0.4, 0.5, 0.3)

    -- Column headers
    local headerY = -42
    local colHeaders = {
        { text=L["COL_SLOT"],        x=PADDING + COL_SLOT   },
        { text=L["COL_ITEM"],        x=PADDING + COL_ITEM   },
        { text=L["COL_ACTUAL"],      x=PADDING + COL_ACTUAL },
        { text=L["COL_RECOMMENDED"], x=PADDING + COL_REC    },
        { text=L["COL_GEMS"],        x=PADDING + COL_GEMS   },
    }
    for _, h in ipairs(colHeaders) do
        local fs = detailFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", h.x, headerY)
        fs:SetText(h.text)
        fs:SetTextColor(0.85, 0.85, 0.65)
    end

    -- Second divider under headers
    local div2 = detailFrame:CreateTexture(nil, "ARTWORK")
    div2:SetPoint("TOPLEFT",  detailFrame, "TOPLEFT",  PADDING, -58)
    div2:SetPoint("TOPRIGHT", detailFrame, "TOPRIGHT", -PADDING, -58)
    div2:SetHeight(1)
    U.SetSolidColor(div2, 0.4, 0.4, 0.5, 0.3)

    -- Slot rows
    for idx, slotId in ipairs(DISPLAY_SLOTS) do
        local rowY = -60 - (idx - 1) * ROW_H

        local slotLabel = detailFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slotLabel:SetPoint("LEFT", detailFrame, "TOPLEFT", PADDING + COL_SLOT, rowY - ROW_H / 2)
        slotLabel:SetWidth(74)
        slotLabel:SetJustifyH("LEFT")
        slotLabel:SetText(U.SlotName(slotId))
        slotLabel:SetTextColor(0.7, 0.7, 0.7)

        -- Item name as a clickable/hoverable button so we can show the item tooltip
        local itemBtn = CreateFrame("Button", nil, detailFrame)
        itemBtn:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", PADDING + COL_ITEM, rowY)
        itemBtn:SetSize(185, ROW_H)

        local itemText = itemBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        itemText:SetPoint("LEFT", itemBtn, "LEFT", 0, 0)
        itemText:SetWidth(185)
        itemText:SetJustifyH("LEFT")

        -- Store the item link on the button; set in PopulateRows
        itemBtn.itemLink = nil
        itemBtn:SetScript("OnEnter", function(self)
            if self.itemLink then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(self.itemLink)
                GameTooltip:Show()
            end
        end)
        itemBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Actual enchant as a clickable Button (right-click to add to recommended)
        local actualBtn = CreateFrame("Button", nil, detailFrame)
        actualBtn:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", PADDING + COL_ACTUAL, rowY)
        actualBtn:SetSize(125, ROW_H)
        actualBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        local actualText = actualBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        actualText:SetPoint("LEFT", actualBtn, "LEFT", 0, 0)
        actualText:SetWidth(125)
        actualText:SetJustifyH("LEFT")

        -- Store per-row state for right-click handler
        actualBtn.enchantWrong = false
        actualBtn.enchantId = 0
        actualBtn.slotId = slotId

        local recBtn = CreateFrame("Button", nil, detailFrame)
        recBtn:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", PADDING + COL_REC, rowY)
        recBtn:SetSize(130, ROW_H)
        recBtn.fullText = nil
        recBtn:SetScript("OnEnter", function(self)
            if self.fullText and self.fullText ~= "" then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.fullText, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        recBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        local recText = recBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        recText:SetPoint("LEFT", recBtn, "LEFT", 0, 0)
        recText:SetWidth(130)
        recText:SetJustifyH("LEFT")

        local gemsText = detailFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        gemsText:SetPoint("LEFT", detailFrame, "TOPLEFT", PADDING + COL_GEMS, rowY - ROW_H / 2)
        gemsText:SetWidth(80)
        gemsText:SetJustifyH("LEFT")

        -- Row striping
        U.AddRowStripe(itemBtn, idx)

        slotRows[slotId] = {
            slotLabel  = slotLabel,
            itemBtn    = itemBtn,
            itemText   = itemText,
            actualBtn  = actualBtn,
            actualText = actualText,
            recBtn     = recBtn,
            recText    = recText,
            gemsText   = gemsText,
        }
    end

    -- Context menu for right-click "add to recommended"
    contextMenu = CreateFrame("Frame", "RIEnchantContextMenu", UIParent, "UIDropDownMenuTemplate")

    -- Wire up right-click handlers for each slot's actualBtn
    for _, slotId in ipairs(DISPLAY_SLOTS) do
        local row = slotRows[slotId]
        row.actualBtn:SetScript("OnClick", function(self, button)
            if button == "RightButton" and self.enchantWrong and self.enchantId > 0 and currentKey then
                local record = RaidInspectorData.GetPlayerByKey(currentKey)
                if not record then return end
                local cls = record.class or "UNKNOWN"
                local sp  = record.spec or { tab=0 }
                if sp.tab == 0 then return end

                local enchName = RaidInspectorBiS.GetEnchantName(self.enchantId) or ("Enchant #" .. self.enchantId)
                local sid = self.slotId
                local menuList = {
                    { text = string.format(L["CONTEXT_ADD_REC"], enchName),
                      func = function()
                          RaidInspectorBiS.AddEnchantOverride(cls, sp.tab, sid, self.enchantId, enchName)
                          -- Re-evaluate flags and refresh
                          local slot = record.slots and record.slots[sid]
                          if slot then
                              RaidInspectorData.FillSlotFlags(slot, sid, cls, sp)
                              RaidInspectorData.ComputeAggregates(record)
                          end
                          RaidInspector.Fire("SCAN_UPDATED")
                          print("|cff00ccff[TRI]|r " .. string.format(L["OVERRIDE_ADDED"],
                              enchName, cls, sp.name, U.SlotName(sid)))
                      end },
                }
                UIDropDownMenu_Initialize(contextMenu, function()
                    for _, item in ipairs(menuList) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = item.text
                        info.func = item.func
                        info.notCheckable = true
                        UIDropDownMenu_AddButton(info)
                    end
                end, "MENU")
                ToggleDropDownMenu(1, nil, contextMenu, "cursor", 0, 0)
            end
        end)
    end
end

-- ── Populate rows ─────────────────────────────────────────────────────────────

local function TruncStr(s, maxLen)
    if not s then return "" end
    if #s <= maxLen then return s end
    return s:sub(1, maxLen - 2) .. ".."
end

local function PopulateRows(record)
    local class   = record.class or "UNKNOWN"
    local spec    = record.spec  or { tab=0, name="???", points=0 }
    local specTab = spec.tab

    for _, slotId in ipairs(DISPLAY_SLOTS) do
        local row   = slotRows[slotId]
        local slot  = record.slots and record.slots[slotId]

        if not slot then
            -- Empty slot
            row.itemBtn.itemLink = nil
            row.itemText:SetText("")
            row.actualBtn.enchantWrong = false
            row.actualBtn.enchantId = 0
            row.actualText:SetText("")
            row.recBtn.fullText = nil
            row.recText:SetText("")
            row.gemsText:SetText("")
        else
            -- Item name (quality color) + store link for tooltip
            local qc = U.QualityColor(slot.quality)
            row.itemText:SetText(TruncStr(slot.itemName, 28))
            row.itemText:SetTextColor(qc.r, qc.g, qc.b)
            row.itemBtn.itemLink = slot.itemLink

            -- Actual enchant
            local enchantRequired = RaidInspectorRules.IsEnchantRequired(slotId, slot, class)
            row.actualBtn.enchantWrong = false
            row.actualBtn.enchantId = slot.enchantId or 0
            if not enchantRequired then
                row.actualText:SetText(L["ENCHANT_NONE_REQ"])
                row.actualText:SetTextColor(0.5, 0.5, 0.5)
                row.recBtn.fullText = nil
                row.recText:SetText(L["ENCHANT_NONE_REQ"])
                row.recText:SetTextColor(0.5, 0.5, 0.5)
            else
                if slot.enchantMissing then
                    row.actualText:SetText(L["ENCHANT_MISSING"])
                    row.actualText:SetTextColor(0.9, 0.1, 0.1)
                elseif slot.enchantWrong then
                    row.actualBtn.enchantWrong = true
                    -- Has enchant but not recommended — resolve name from lookup
                    local enchName = RaidInspectorBiS.GetEnchantName(slot.enchantId)
                    if enchName then
                        row.actualText:SetText(TruncStr(enchName, 20) .. " (!)")
                    else
                        row.actualText:SetText("Enchant #" .. slot.enchantId .. " (!)")
                    end
                    row.actualText:SetTextColor(1, 0.5, 0)
                else
                    -- Has correct enchant — resolve name from lookup or rec
                    local enchName = RaidInspectorBiS.GetEnchantName(slot.enchantId)
                    if not enchName then
                        enchName = RaidInspectorBiS.GetRecommendedEnchantName(class, specTab, slotId)
                    end
                    if enchName then
                        row.actualText:SetText(TruncStr(enchName, 22))
                        row.actualText:SetTextColor(0.1, 0.9, 0.1)
                    else
                        row.actualText:SetText("Enchanted")
                        row.actualText:SetTextColor(0.1, 0.9, 0.1)
                    end
                end

                -- Recommended enchant column
                if specTab == 0 then
                    row.recBtn.fullText = nil
                    row.recText:SetText(L["SCAN_FOR_REC"])
                    row.recText:SetTextColor(0.5, 0.5, 0.5)
                else
                    local recName = RaidInspectorBiS.GetRecommendedEnchantName(class, specTab, slotId)
                    if recName then
                        row.recBtn.fullText = recName
                        row.recText:SetText(TruncStr(recName, 20))
                        row.recText:SetTextColor(0.9, 0.9, 0.7)
                    else
                        row.recBtn.fullText = nil
                        row.recText:SetText("\226\128\148")
                        row.recText:SetTextColor(0.5, 0.5, 0.5)
                    end
                end
            end

            -- Gems column — per-gem colored indicators
            if slot.gemSlotsExpected > 0 then
                local parts = {}
                local gemIdx = 0
                for i = 1, 4 do
                    if slot.gems[i] and slot.gems[i] ~= 0 then
                        gemIdx = gemIdx + 1
                        local q = (slot.gemQualities and slot.gemQualities[i]) or 0
                        if q == 2 then
                            -- Green quality gem = orange warning
                            table.insert(parts, "|cffff8800O|r")
                        else
                            -- Good gem = green
                            table.insert(parts, "|cff00ff00O|r")
                        end
                    end
                end
                -- Empty sockets = red X
                local missing = slot.gemSlotsExpected - slot.gemsFilled
                for i = 1, missing do
                    table.insert(parts, "|cffff0000X|r")
                end
                row.gemsText:SetText(table.concat(parts, " "))
            else
                row.gemsText:SetText("")
            end
        end
    end
end

-- ── Public API ────────────────────────────────────────────────────────────────

function UD.ShowPlayer(keyOrName)
    if not detailFrame then BuildDetailFrame() end

    -- Accept either a full "Name-Realm" key or just a name
    local record = RaidInspectorData.GetPlayerByKey(keyOrName)
    if not record then
        -- Try by name only (search players table)
        for k, r in pairs(RaidInspectorData.GetAllPlayers()) do
            if r.name == keyOrName then
                record = r
                keyOrName = k
                break
            end
        end
    end

    if not record then
        detailFrame:Hide()
        return
    end

    currentKey = keyOrName

    -- Header
    local class   = record.class or "UNKNOWN"
    local spec    = record.spec  or { tab=0, name="???", points=0 }
    local cc      = U.ClassColor(class)
    local classStr = (class ~= "UNKNOWN") and (class:sub(1,1) .. class:sub(2):lower()) or "?"

    if spec.tab ~= 0 then
        headerText:SetText(string.format(
            L["DETAIL_TITLE"],
            record.name, classStr, spec.name, spec.points
        ))
    else
        headerText:SetText(string.format(
            L["DETAIL_SPEC_UNKNOWN"],
            record.name, classStr
        ))
    end
    headerText:SetTextColor(cc.r, cc.g, cc.b)

    PopulateRows(record)

    detailFrame:Show()
end

function UD.Hide()
    if detailFrame then detailFrame:Hide() end
end

function UD.IsShown()
    return detailFrame and detailFrame:IsShown()
end

function UD.GetCurrentKey()
    if detailFrame and detailFrame:IsShown() then
        return currentKey
    end
    return nil
end

-- Refresh when scan data updates
RaidInspector.On("SCAN_UPDATED", function()
    if detailFrame and detailFrame:IsShown() and currentKey then
        local record = RaidInspectorData.GetPlayerByKey(currentKey)
        if record then PopulateRows(record) end
    end
end)

RaidInspector.On("DATA_CLEARED", function()
    UD.Hide()
end)
