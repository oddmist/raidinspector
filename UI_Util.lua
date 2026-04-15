-- UI_Util.lua — Shared UI helpers: colors, slot names, status textures

RaidInspectorUIUtil = {}
local U = RaidInspectorUIUtil
local L = RaidInspectorL

-- ── Class colors ──────────────────────────────────────────────────────────────

function U.ClassColor(class)
    if RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
        return RAID_CLASS_COLORS[class]
    end
    return { r=0.8, g=0.8, b=0.8 }  -- fallback gray
end

function U.ClassColorStr(class)
    local c = U.ClassColor(class)
    return string.format("|cff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
end

-- ── Item quality colors ───────────────────────────────────────────────────────

local QUALITY_COLORS = {
    [0] = { r=0.62, g=0.62, b=0.62 },  -- Poor (gray)
    [1] = { r=1,    g=1,    b=1    },  -- Common (white)
    [2] = { r=0.12, g=1,    b=0    },  -- Uncommon (green)
    [3] = { r=0,    g=0.44, b=0.87 },  -- Rare (blue)
    [4] = { r=0.64, g=0.21, b=0.93 },  -- Epic (purple)
    [5] = { r=1,    g=0.50, b=0    },  -- Legendary (orange)
}

function U.QualityColor(quality)
    return QUALITY_COLORS[quality] or QUALITY_COLORS[1]
end

function U.QualityColorStr(quality)
    local c = U.QualityColor(quality)
    return string.format("|cff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
end

-- ── Status colors ─────────────────────────────────────────────────────────────

U.STATUS_COLORS = {
    ok       = { r=0.1,  g=0.9,  b=0.1  },  -- green
    warn     = { r=1,    g=0.85, b=0    },  -- yellow
    wrong    = { r=1,    g=0.5,  b=0    },  -- orange
    missing  = { r=0.9,  g=0.1,  b=0.1  },  -- red
    unscanned= { r=0.5,  g=0.5,  b=0.5  },  -- gray
    offline  = { r=0.4,  g=0.4,  b=0.4  },  -- dark gray
    timeout  = { r=0.4,  g=0.4,  b=0.4  },  -- dark gray
}

function U.StatusColor(status)
    return U.STATUS_COLORS[status] or U.STATUS_COLORS.unscanned
end

function U.SetTextColor(fontString, r, g, b)
    fontString:SetTextColor(r, g, b)
end

function U.SetStatusColor(fontString, status)
    local c = U.StatusColor(status)
    fontString:SetTextColor(c.r, c.g, c.b)
end

-- ── Status summary string ─────────────────────────────────────────────────────

function U.StatusSummary(record)
    if not record then return L["STATUS_UNSCANNED"] end
    local s = record.status

    if s == "offline" then return L["OFFLINE"] end
    if s == "timeout" then return L["TIMEOUT"] end
    if s == "unscanned" then return L["STATUS_UNSCANNED"] end
    if s == "ok" then return "" end

    local parts = {}
    if record.missingEnchants > 0 then
        table.insert(parts, string.format(L["MISSING_ENC"], record.missingEnchants))
    end
    if record.wrongEnchants > 0 then
        table.insert(parts, string.format(L["WRONG_ENC"], record.wrongEnchants))
    end
    if record.missingGems > 0 then
        table.insert(parts, string.format(L["MISSING_GEMS"], record.missingGems))
    end
    if (record.lowQualityGems or 0) > 0 then
        table.insert(parts, string.format(L["LOW_QUALITY_GEMS"], record.lowQualityGems))
    end
    return table.concat(parts, ", ")
end

-- ── Slot names ────────────────────────────────────────────────────────────────

function U.SlotName(slotId)
    return L["SLOT_" .. slotId] or ("Slot " .. slotId)
end

-- ── Backdrop helper ───────────────────────────────────────────────────────────
-- TBC Classic Anniversary uses BackdropTemplateMixin (like retail).
-- The frame MUST be created with "BackdropTemplate" inherits for SetBackdrop
-- to exist. If the caller forgot, we apply the mixin here as a safety net.

local BACKDROP_INFO = {
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true, tileSize = 16, edgeSize = 16,
    insets   = { left=4, right=4, top=4, bottom=4 },
}

function U.SetBasicBackdrop(frame)
    -- Apply BackdropTemplateMixin if SetBackdrop is missing
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
        frame:HookScript("OnSizeChanged", frame.OnBackdropSizeChanged)
    end
    frame:SetBackdrop(BACKDROP_INFO)
    frame:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
end

-- Solid color texture helper (avoids SetTexture(r,g,b,a) which breaks in retail-API clients)
function U.SetSolidColor(texture, r, g, b, a)
    texture:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    texture:SetVertexColor(r, g, b)
    if a then texture:SetAlpha(a) end
end

-- Row stripe helper for alternating row backgrounds
function U.AddRowStripe(row, index)
    if index % 2 == 0 then
        local stripe = row:CreateTexture(nil, "BACKGROUND")
        stripe:SetAllPoints()
        U.SetSolidColor(stripe, 1, 1, 1, 0.03)
    end
end

-- ── Font string helpers ───────────────────────────────────────────────────────

function U.NewLabel(parent, text, size, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    if size then
        local font, _, flags = fs:GetFont()
        fs:SetFont(font, size, flags)
    end
    fs:SetJustifyH(justify or "LEFT")
    if text then fs:SetText(text) end
    return fs
end
