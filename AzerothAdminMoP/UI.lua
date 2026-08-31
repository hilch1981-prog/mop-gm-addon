local AAM = AzerothAdminMoP

local frame = CreateFrame("Frame", "AzerothAdminMoPFrame", UIParent)
frame:SetSize(280, 220)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:Hide()

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})

frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint(1)
    AzerothAdminMoPDB.point = point
    AzerothAdminMoPDB.relativePoint = relativePoint
    AzerothAdminMoPDB.x = x
    AzerothAdminMoPDB.y = y
end)

frame:SetScript("OnShow", function(self)
    self:ClearAllPoints()
    self:SetPoint(
        AzerothAdminMoPDB.point or "CENTER",
        UIParent,
        AzerothAdminMoPDB.relativePoint or "CENTER",
        AzerothAdminMoPDB.x or 0,
        AzerothAdminMoPDB.y or 0
    )
end)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -18)
title:SetText("AzerothAdmin MoP")

local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
subtitle:SetPoint("TOP", title, "BOTTOM", 0, -6)
subtitle:SetText("5.4.8 / Build 18414 / alpha")

local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)

for index, entry in ipairs(AAM.commands) do
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetSize(105, 28)
    local column = (index - 1) % 2
    local row = math.floor((index - 1) / 2)
    button:SetPoint("TOPLEFT", 28 + (column * 120), -72 - (row * 40))
    button:SetText(entry.label)
    button:SetScript("OnClick", function()
        AAM:SendCommand(entry.command)
    end)
end

local warning = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
warning:SetPoint("BOTTOM", 0, 22)
warning:SetWidth(235)
warning:SetJustifyH("CENTER")
warning:SetText("Alpha: commands require validation on MOP_V2_Repack")
