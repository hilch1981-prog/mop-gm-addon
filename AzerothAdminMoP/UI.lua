local AAM = AzerothAdminMoP
local L = AAM.L or {}

local frame = CreateFrame("Frame", "AzerothAdminMoPFrame", UIParent)
frame:SetSize(760, 520)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:Hide()
frame:SetBackdrop({
  bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
  tile=true, tileSize=32, edgeSize=32,
  insets={left=11,right=12,top=12,bottom=11},
})

frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local point, _, relativePoint, x, y = self:GetPoint(1)
  if AzerothAdminMoPDB then
    AzerothAdminMoPDB.point, AzerothAdminMoPDB.relativePoint = point, relativePoint
    AzerothAdminMoPDB.x, AzerothAdminMoPDB.y = x, y
  end
end)
frame:SetScript("OnShow", function(self)
  if not AzerothAdminMoPDB then return end
  self:ClearAllPoints()
  self:SetPoint(AzerothAdminMoPDB.point or "CENTER", UIParent, AzerothAdminMoPDB.relativePoint or "CENTER", AzerothAdminMoPDB.x or 0, AzerothAdminMoPDB.y or 0)
end)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 22, -18)
title:SetText(L.title or "AzerothAdmin MoP")
local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
subtitle:SetPoint("LEFT", title, "RIGHT", 12, 0)
subtitle:SetText((L.subtitle or "MoP 5.4.8 / Build 18414") .. "  |  " .. AAM.version)
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)

local note = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
note:SetPoint("TOPLEFT", 22, -43)
note:SetText(L.note or "MOP_V2_Repack command adapter")

local dataBrowserButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
dataBrowserButton:SetSize(150, 25)
dataBrowserButton:SetPoint("TOPRIGHT", -40, -38)
dataBrowserButton:SetText("MoP SQL 데이터")
dataBrowserButton:SetScript("OnClick", function()
  if AAM.ShowDataBrowser then AAM.ShowDataBrowser() end
end)

local argLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
argLabel:SetPoint("TOPLEFT", 180, -70)
argLabel:SetText(L.arg or "Argument")
local argBox = CreateFrame("EditBox", "AzerothAdminMoPArgBox", frame, "InputBoxTemplate")
argBox:SetSize(330, 26)
argBox:SetPoint("LEFT", argLabel, "RIGHT", 10, 0)
argBox:SetAutoFocus(false)
argBox:SetMaxLetters(180)

local rawBox = CreateFrame("EditBox", "AzerothAdminMoPRawBox", frame, "InputBoxTemplate")
rawBox:SetSize(430, 26)
rawBox:SetPoint("BOTTOMLEFT", 180, 25)
rawBox:SetAutoFocus(false)
rawBox:SetMaxLetters(220)
rawBox:SetText("")
local rawBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
rawBtn:SetSize(105, 26)
rawBtn:SetPoint("LEFT", rawBox, "RIGHT", 8, 0)
rawBtn:SetText(L.send or "Send")
rawBtn:SetScript("OnClick", function() AAM:SendCommand(rawBox:GetText()); rawBox:SetText("") end)
rawBox:SetScript("OnEnterPressed", function(self) AAM:SendCommand(self:GetText()); self:SetText(""); self:ClearFocus() end)
rawBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
argBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local categoryButtons = {}
local commandButtons = {}
local currentGroup

local function setButtonTooltip(button, entry)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(entry[2], 1, 0.82, 0)
    if entry[3] then GameTooltip:AddLine((L.arg or "Argument") .. ": " .. entry[3], 1, 1, 1) end
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function renderGroup(key)
  local group = AAM:GetGroup(key) or AAM.CommandGroups[1]
  if not group then return end
  currentGroup = group.key
  if AzerothAdminMoPDB then AzerothAdminMoPDB.lastGroup = currentGroup end
  for _, b in ipairs(commandButtons) do b:Hide() end
  for index, entry in ipairs(group.commands) do
    local b = commandButtons[index]
    if not b then
      b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
      b:SetSize(165, 30)
      commandButtons[index] = b
    end
    local col = (index - 1) % 3
    local row = math.floor((index - 1) / 3)
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", 180 + col * 177, -112 - row * 39)
    b:SetText(entry[1])
    b:SetScript("OnClick", function()
      local command, needed = AAM:BuildCommand(entry, argBox:GetText())
      if not command then
        AAM:Print((L.arg or "Argument") .. ": " .. tostring(needed))
        argBox:SetFocus()
        return
      end
      AAM:SendCommand(command)
    end)
    setButtonTooltip(b, entry)
    b:Show()
  end
  for _, cb in ipairs(categoryButtons) do
    cb:UnlockHighlight()
    if cb.groupKey == group.key then cb:LockHighlight() end
  end
end

for index, group in ipairs(AAM.CommandGroups or {}) do
  local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  b:SetSize(135, 28)
  b:SetPoint("TOPLEFT", 25, -72 - (index - 1) * 34)
  b:SetText(group.label)
  b.groupKey = group.key
  b:SetScript("OnClick", function(self) renderGroup(self.groupKey) end)
  categoryButtons[index] = b
end

local histTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
histTitle:SetPoint("BOTTOMLEFT", 25, 95)
histTitle:SetText("History")
local hist = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hist:SetPoint("TOPLEFT", histTitle, "BOTTOMLEFT", 0, -5)
hist:SetWidth(130)
hist:SetHeight(65)
hist:SetJustifyH("LEFT")
hist:SetJustifyV("TOP")

function AAM:RefreshHistory()
  local lines = {}
  for i = 1, math.min(4, #(self.history or {})) do lines[#lines + 1] = self.history[i] end
  hist:SetText(table.concat(lines, "\n"))
end

frame:HookScript("OnShow", function()
  renderGroup((AzerothAdminMoPDB and AzerothAdminMoPDB.lastGroup) or "general")
  AAM:RefreshHistory()
end)

if AAM.CommandGroups and AAM.CommandGroups[1] then renderGroup("general") end
