local AAM = AzerothAdminMoP
local L = AAM.L or {}

local DEFAULT_X = 7
local DEFAULT_Y = -38

function AAM:TogglePanel()
  local panel = AzerothAdminMoPFrame
  if not panel then return end
  if panel:IsShown() then panel:Hide() else panel:Show() end
end

function AAM:CreateMinimapButton()
  if self.minimapButton or not Minimap then return end

  local button = CreateFrame("Button", "AzerothAdminMoPMinimapButton", UIParent)
  button:SetSize(34, 34)
  button:SetFrameStrata("MEDIUM")
  button:SetMovable(true)
  button:SetClampedToScreen(true)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
  button:RegisterForDrag("LeftButton")

  local db = AzerothAdminMoPDB or {}
  if db.minimapX and db.minimapY then
    button:SetPoint("CENTER", UIParent, "CENTER", db.minimapX, db.minimapY)
  else
    button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", DEFAULT_X, DEFAULT_Y)
  end

  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
  icon:SetSize(23, 23)
  icon:SetPoint("CENTER", button, "CENTER", 0, 0)
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetSize(54, 54)
  border:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
  button.aamBorder = border

  local highlight = button:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  highlight:SetBlendMode("ADD")
  highlight:SetSize(34, 34)
  highlight:SetPoint("CENTER", button, "CENTER", 0, 0)

  button:SetScript("OnEnter", function(self)
    if self.aamBorder then self.aamBorder:SetVertexColor(0.35, 1, 1, 1) end
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(L.minimapTitle or "AzerothAdmin MoP", 1, 0.82, 0.18)
    GameTooltip:AddLine(L.minimapLeft or "Left click: GM panel", 1, 1, 1)
    GameTooltip:AddLine(L.minimapRight or "Right click: Teleports", 1, 1, 1)
    GameTooltip:AddLine(L.minimapMiddle or "Middle click: Favorite teleports", 1, 1, 1)
    GameTooltip:AddLine(L.minimapDrag or "Drag: Move icon", 0.72, 0.72, 0.72)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function(self)
    if self.aamBorder then self.aamBorder:SetVertexColor(1, 1, 1, 1) end
    GameTooltip:Hide()
  end)
  button:SetScript("OnClick", function(_, mouseButton)
    if mouseButton == "RightButton" then
      if AAM.ShowDataBrowser then AAM:ShowDataBrowser("Teleports", false) end
    elseif mouseButton == "MiddleButton" then
      if AAM.ShowDataBrowser then AAM:ShowDataBrowser("Teleports", true) end
    else
      AAM:TogglePanel()
    end
  end)
  button:SetScript("OnDragStart", function(self) self:StartMoving() end)
  button:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local centerX, centerY = UIParent:GetCenter()
    if not x or not y or not centerX or not centerY then return end
    x = x - centerX
    y = y - centerY
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "CENTER", x, y)
    AzerothAdminMoPDB = AzerothAdminMoPDB or {}
    AzerothAdminMoPDB.minimapX = x
    AzerothAdminMoPDB.minimapY = y
  end)

  self.minimapButton = button
  button:Show()
end

function AAM:ToggleMinimapButton()
  if not self.minimapButton then self:CreateMinimapButton() end
  if not self.minimapButton then return end
  if self.minimapButton:IsShown() then self.minimapButton:Hide() else self.minimapButton:Show() end
end

function AAM:ResetMinimapButton()
  AzerothAdminMoPDB = AzerothAdminMoPDB or {}
  AzerothAdminMoPDB.minimapX = nil
  AzerothAdminMoPDB.minimapY = nil
  if not self.minimapButton then self:CreateMinimapButton() end
  if not self.minimapButton then return end
  self.minimapButton:ClearAllPoints()
  self.minimapButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", DEFAULT_X, DEFAULT_Y)
  self.minimapButton:Show()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then AAM:CreateMinimapButton() end
end)
