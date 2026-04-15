-- UI_ImportExport.lua — Base64 import/export for enchant overrides

RaidInspectorUIImportExport = {}
local IE = RaidInspectorUIImportExport
local U  = RaidInspectorUIUtil
local L  = RaidInspectorL

local WINDOW_W = 450
local WINDOW_H = 320
local PADDING  = 10

local ieFrame = nil

-- ── Base64 Codec ─────────────────────────────────────────────────────────────

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function Base64Encode(data)
    local out = {}
    local pad = 0
    local len = #data

    for i = 1, len, 3 do
        local b1 = string.byte(data, i)
        local b2 = i + 1 <= len and string.byte(data, i + 1) or 0
        local b3 = i + 2 <= len and string.byte(data, i + 2) or 0

        local n = b1 * 65536 + b2 * 256 + b3

        local c1 = math.floor(n / 262144) + 1
        local c2 = math.floor(n / 4096) % 64 + 1
        local c3 = math.floor(n / 64) % 64 + 1
        local c4 = n % 64 + 1

        table.insert(out, string.sub(B64, c1, c1))
        table.insert(out, string.sub(B64, c2, c2))
        table.insert(out, (i + 1 <= len) and string.sub(B64, c3, c3) or "=")
        table.insert(out, (i + 2 <= len) and string.sub(B64, c4, c4) or "=")
    end

    return table.concat(out)
end

local function Base64Decode(data)
    data = data:gsub("[^A-Za-z0-9+/=]", "")
    local out = {}

    for i = 1, #data, 4 do
        local c1 = (string.find(B64, string.sub(data, i, i), 1, true) or 1) - 1
        local c2 = (string.find(B64, string.sub(data, i+1, i+1), 1, true) or 1) - 1
        local c3str = string.sub(data, i+2, i+2)
        local c4str = string.sub(data, i+3, i+3)
        local c3 = c3str ~= "=" and (string.find(B64, c3str, 1, true) or 1) - 1 or 0
        local c4 = c4str ~= "=" and (string.find(B64, c4str, 1, true) or 1) - 1 or 0

        local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4

        table.insert(out, string.char(math.floor(n / 65536) % 256))
        if c3str ~= "=" then
            table.insert(out, string.char(math.floor(n / 256) % 256))
        end
        if c4str ~= "=" then
            table.insert(out, string.char(n % 256))
        end
    end

    return table.concat(out)
end

-- ── Lua Table Serializer ─────────────────────────────────────────────────────

local function Serialize(val)
    if type(val) == "number" then
        return tostring(val)
    elseif type(val) == "string" then
        return string.format("%q", val)
    elseif type(val) == "table" then
        local parts = {}
        for k, v in pairs(val) do
            table.insert(parts, "[" .. Serialize(k) .. "]=" .. Serialize(v))
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "nil"
end

-- ── Safe Deserializer ────────────────────────────────────────────────────────
-- Only allows table constructors, strings, and numbers — no function calls.

local function SafeDeserialize(str)
    -- Validate: only allow safe characters (no function calls, no identifiers except table keys)
    if str:find("[^%w%s%{%}%[%]%=,%.%-%+\"\\']") then
        return nil
    end
    -- Block any function-like patterns
    if str:find("%a+%s*%(") then
        return nil
    end

    local fn, err = loadstring("return " .. str)
    if not fn then return nil end

    -- Sandbox: no access to globals
    setfenv(fn, {})
    local ok, result = pcall(fn)
    if not ok or type(result) ~= "table" then return nil end
    return result
end

-- ── Export ────────────────────────────────────────────────────────────────────

local function DoExport(editBox)
    local db = RaidInspectorDB and RaidInspectorDB.enchantOverrides
    if not db or not next(db) then
        editBox:SetText("")
        return
    end
    local serialized = Serialize(db)
    local encoded = Base64Encode(serialized)
    editBox:SetText(encoded)
    editBox:HighlightText()
    editBox:SetFocus()
end

-- ── Import (merge strategy: union IDs per class/spec/slot) ───────────────────

local function DoImport(editBox)
    local raw = editBox:GetText()
    if not raw or raw == "" then return end

    local decoded = Base64Decode(raw)
    if not decoded or decoded == "" then
        print("|cff00ccff[TRI]|r " .. L["IMPORT_FAILED"])
        return
    end

    local imported = SafeDeserialize(decoded)
    if not imported then
        print("|cff00ccff[TRI]|r " .. L["IMPORT_FAILED"])
        return
    end

    -- Merge into existing overrides
    if not RaidInspectorDB then return end
    RaidInspectorDB.enchantOverrides = RaidInspectorDB.enchantOverrides or {}
    local db = RaidInspectorDB.enchantOverrides

    local count = 0
    for class, specTbl in pairs(imported) do
        if type(class) == "string" and type(specTbl) == "table" then
            db[class] = db[class] or {}
            for specTab, slotTbl in pairs(specTbl) do
                if type(specTab) == "number" and type(slotTbl) == "table" then
                    db[class][specTab] = db[class][specTab] or {}
                    for slotId, entry in pairs(slotTbl) do
                        if type(slotId) == "number" and type(entry) == "table" and type(entry.ids) == "table" then
                            for _, enchantId in ipairs(entry.ids) do
                                if type(enchantId) == "number" then
                                    local name = RaidInspectorBiS.GetEnchantName(enchantId) or
                                                 (type(entry.name) == "string" and entry.name) or
                                                 ("Enchant #" .. enchantId)
                                    RaidInspectorBiS.AddEnchantOverride(class, specTab, slotId, enchantId, name)
                                    count = count + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    print("|cff00ccff[TRI]|r " .. string.format(L["IMPORT_SUCCESS"], count))
    RaidInspector.Fire("SCAN_UPDATED")
    editBox:SetText("")
end

-- ── Build frame ──────────────────────────────────────────────────────────────

local function BuildFrame()
    ieFrame = CreateFrame("Frame", "RaidInspectorImportExportFrame", UIParent, "BackdropTemplate")
    ieFrame:SetSize(WINDOW_W, WINDOW_H)
    ieFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    ieFrame:SetMovable(true)
    ieFrame:EnableMouse(true)
    ieFrame:RegisterForDrag("LeftButton")
    ieFrame:SetScript("OnDragStart", ieFrame.StartMoving)
    ieFrame:SetScript("OnDragStop", ieFrame.StopMovingOrSizing)
    ieFrame:SetClampedToScreen(true)
    ieFrame:Hide()
    ieFrame:SetFrameStrata("DIALOG")
    U.SetBasicBackdrop(ieFrame)

    -- Title
    local title = ieFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOPLEFT", ieFrame, "TOPLEFT", PADDING + 4, -PADDING)
    title:SetText(L["IMPORT_EXPORT"])

    -- Close
    local closeBtn = CreateFrame("Button", nil, ieFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", ieFrame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() ieFrame:Hide() end)

    -- Instructions
    local instrLabel = ieFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    instrLabel:SetPoint("TOPLEFT", ieFrame, "TOPLEFT", PADDING + 4, -34)
    instrLabel:SetText(L["EXPORT_INSTRUCTIONS"])

    -- Scrollable edit box
    local scrollBg = CreateFrame("ScrollFrame", "RIImportExportScroll", ieFrame, "UIPanelScrollFrameTemplate")
    scrollBg:SetPoint("TOPLEFT", ieFrame, "TOPLEFT", PADDING + 4, -52)
    scrollBg:SetPoint("BOTTOMRIGHT", ieFrame, "BOTTOMRIGHT", -28, 40)

    local editBox = CreateFrame("EditBox", "RIImportExportEditBox", scrollBg)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetWidth(WINDOW_W - 50)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scrollBg:SetScrollChild(editBox)

    -- Buttons at bottom
    local exportBtn = CreateFrame("Button", nil, ieFrame, "UIPanelButtonTemplate")
    exportBtn:SetSize(80, 22)
    exportBtn:SetPoint("BOTTOMLEFT", ieFrame, "BOTTOMLEFT", PADDING, PADDING)
    exportBtn:SetText(L["EXPORT"])
    exportBtn:SetScript("OnClick", function()
        instrLabel:SetText(L["EXPORT_INSTRUCTIONS"])
        DoExport(editBox)
    end)

    local importBtn = CreateFrame("Button", nil, ieFrame, "UIPanelButtonTemplate")
    importBtn:SetSize(80, 22)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 8, 0)
    importBtn:SetText(L["IMPORT"])
    importBtn:SetScript("OnClick", function()
        DoImport(editBox)
    end)

    -- Switch to import mode label
    local importLabel = CreateFrame("Button", nil, ieFrame, "UIPanelButtonTemplate")
    importLabel:SetSize(110, 22)
    importLabel:SetPoint("BOTTOMRIGHT", ieFrame, "BOTTOMRIGHT", -PADDING, PADDING)
    importLabel:SetText(L["IMPORT_INSTRUCTIONS"]:sub(1, 20) .. "...")
    importLabel:SetScript("OnClick", function()
        instrLabel:SetText(L["IMPORT_INSTRUCTIONS"])
        editBox:SetText("")
        editBox:SetFocus()
    end)
end

-- ── Public API ───────────────────────────────────────────────────────────────

function IE.Toggle()
    if not ieFrame then BuildFrame() end
    if ieFrame:IsShown() then
        ieFrame:Hide()
    else
        ieFrame:Show()
    end
end

function IE.Show()
    if not ieFrame then BuildFrame() end
    ieFrame:Show()
end

function IE.Hide()
    if ieFrame then ieFrame:Hide() end
end
