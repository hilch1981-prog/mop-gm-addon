local A = AzerothAdminMoP

local frame = CreateFrame("Frame", "AzerothAdminMoPFrame", UIParent)
frame:SetSize(540, 390)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:Hide()

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", frame, "TOP", 0, -16)
title:SetText(A:L("TITLE"))

local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

local tabContainer = CreateFrame("Frame", nil, frame)
tabContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -46)
tabContainer:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -46)
tabContainer:SetHeight(28)

local content = CreateFrame("Frame", nil, frame)
content:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -80)
content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)

local panels = {}

table.sort(A.panelOrder, function(left, right)
    return (A.panels[left].order or 100) < (A.panels[right].order or 100)
end)

local function showPanel(key)
    for panelKey, panel in pairs(panels) do
        if panelKey == key then
            panel:Show()
        else
            panel:Hide()
        end
    end
end

for index, key in ipairs(A.panelOrder) do
    local info = A.panels[key]

    local tab = CreateFrame("Button", nil, tabContainer, "UIPanelButtonTemplate")
    tab:SetSize(112, 24)
    tab:SetPoint("LEFT", tabContainer, "LEFT", (index - 1) * 118, 0)
    tab:SetText(A:L(info.titleKey))
    tab:SetScript("OnClick", function() showPanel(key) end)

    local panel = CreateFrame("Frame", nil, content)
    panel:SetAllPoints(content)
    panel:Hide()
    panels[key] = panel

    if info.builder then
        info.builder(panel)
    end
end

if A.panelOrder[1] then
    showPanel(A.panelOrder[1])
end

A.frame = frame

function A:Toggle()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

A:Print("loaded. Use /aamop")
