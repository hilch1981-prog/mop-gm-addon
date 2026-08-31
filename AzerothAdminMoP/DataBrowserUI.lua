local AAM = AzerothAdminMoP

local frame = CreateFrame("Frame", "AzerothAdminMoPDataBrowser", UIParent)
frame:SetSize(720, 520)
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
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 20, -18)
title:SetText("Chipa MoP SQL Browser")
local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", 20, -42)
subtitle:SetText("MOP_V2_Repack world SQL + koKR patch index")
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)

local kinds = {
  {"Items", "아이템"},
  {"Quests", "퀘스트"},
  {"Creatures", "NPC/크리처"},
  {"Teleports", "순간이동"},
}
local currentKind = "Items"
local results = {}

local search = CreateFrame("EditBox", "AzerothAdminMoPDataSearch", frame, "InputBoxTemplate")
search:SetSize(360, 28)
search:SetPoint("TOPLEFT", 180, -72)
search:SetAutoFocus(false)
search:SetMaxLetters(120)

local countText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
countText:SetPoint("LEFT", search, "RIGHT", 10, 0)

local rowButtons = {}
local function render()
  results = AAM:SearchData(currentKind, search:GetText(), 50)
  countText:SetText(string.format("%d / %d", #results, #(AAM.Data[currentKind] or {})))
  for i = 1, 12 do
    local row = results[i]
    local b = rowButtons[i]
    if row then
      b.row = row
      b:SetText(AAM:DescribeDataRow(currentKind, row))
      b:Show()
    else
      b.row = nil
      b:Hide()
    end
  end
end

for i = 1, 12 do
  local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  b:SetSize(500, 28)
  b:SetPoint("TOPLEFT", 180, -112 - (i - 1) * 31)
  b:SetScript("OnClick", function(self)
    if self.row then AAM:DataAction(currentKind, self.row) end
  end)
  rowButtons[i] = b
end

for i, info in ipairs(kinds) do
  local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  b:SetSize(135, 30)
  b:SetPoint("TOPLEFT", 25, -72 - (i - 1) * 38)
  b:SetText(info[2])
  b:SetScript("OnClick", function()
    currentKind = info[1]
    search:SetText("")
    render()
  end)
end

local help = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
help:SetPoint("BOTTOMLEFT", 25, 25)
help:SetWidth(650)
help:SetJustifyH("LEFT")
help:SetText("검색: 이름 또는 정확한 ID  |  결과 클릭: 아이템 지급 / 퀘스트 추가 / NPC 위치 이동 / 텔레포트 실행  |  최대 50건 중 12건 표시")

search:SetScript("OnTextChanged", function() render() end)
search:SetScript("OnEnterPressed", function(self) self:ClearFocus(); render() end)
search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
frame:SetScript("OnShow", render)

SLASH_AZEROTHADMINMOPDB1 = "/aadb"
SlashCmdList.AZEROTHADMINMOPDB = function(msg)
  if frame:IsShown() then frame:Hide() else frame:Show() end
end

AAM.ShowDataBrowser = function()
  frame:Show()
end
