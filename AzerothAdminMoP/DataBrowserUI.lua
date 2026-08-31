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
local currentFavoritesOnly = false
local results = {}
local pageOffset = 0
local pageSize = 12
local hasMore = false
local kindExists = { Items=true, Quests=true, Creatures=true, Teleports=true }

local search = CreateFrame("EditBox", "AzerothAdminMoPDataSearch", frame, "InputBoxTemplate")
search:SetSize(285, 28)
search:SetPoint("TOPLEFT", 180, -72)
search:SetAutoFocus(false)
search:SetMaxLetters(120)

local countText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
countText:SetPoint("TOPLEFT", 565, -80)

local rowButtons = {}
local function render()
  local matched
  results, hasMore, matched = AAM:SearchData(currentKind, search:GetText(), pageSize, pageOffset, currentFavoritesOnly)
  local first = #results > 0 and pageOffset + 1 or 0
  local last = pageOffset + #results
  if currentFavoritesOnly then
    countText:SetText(string.format("%d-%d / 즐겨찾기", first, last))
    subtitle:SetText("즐겨찾기 순간이동  |  우클릭으로 즐겨찾기 해제")
  else
    countText:SetText(string.format("%d-%d / 전체 %d", first, last, #(AAM.Data[currentKind] or {})))
    subtitle:SetText("MOP_V2_Repack world SQL + koKR patch index")
  end
  for i = 1, pageSize do
    local row = results[i]
    local b = rowButtons[i]
    if row then
      b.row = row
      local favorite = AAM:IsDataFavorite(currentKind, row[1])
      b:SetText((favorite and "★ " or "") .. AAM:DescribeDataRow(currentKind, row))
      b:Show()
    else
      b.row = nil
      b:Hide()
    end
  end
end

local searchButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
searchButton:SetSize(80, 28)
searchButton:SetPoint("LEFT", search, "RIGHT", 8, 0)
searchButton:SetText("검색")
searchButton:SetScript("OnClick", function() pageOffset = 0; render() end)

for i = 1, pageSize do
  local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  b:SetSize(500, 28)
  b:SetPoint("TOPLEFT", 180, -112 - (i - 1) * 31)
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  b:SetScript("OnClick", function(self, mouseButton)
    if not self.row then return end
    if mouseButton == "RightButton" and currentKind == "Teleports" then
      AAM:ToggleDataFavorite(currentKind, self.row)
      pageOffset = 0
      render()
    else
      AAM:DataAction(currentKind, self.row)
    end
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
    currentFavoritesOnly = false
    search:SetText("")
    pageOffset = 0
    render()
  end)
end

local previous = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
previous:SetSize(90, 26)
previous:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -125, 25)
previous:SetText("이전")
previous:SetScript("OnClick", function()
  pageOffset = math.max(0, pageOffset - pageSize)
  render()
end)

local nextPage = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
nextPage:SetSize(90, 26)
nextPage:SetPoint("LEFT", previous, "RIGHT", 10, 0)
nextPage:SetText("다음")
nextPage:SetScript("OnClick", function()
  if hasMore then pageOffset = pageOffset + pageSize; render() end
end)

local help = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
help:SetPoint("BOTTOMLEFT", 25, 25)
help:SetWidth(390)
help:SetJustifyH("LEFT")
help:SetText("이름 또는 정확한 ID 검색  |  좌클릭: 실행  |  순간이동 우클릭: 즐겨찾기 등록/해제")

search:SetScript("OnEnterPressed", function(self) self:ClearFocus(); pageOffset = 0; render() end)
search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
frame:SetScript("OnShow", function() pageOffset = 0; render() end)

SLASH_AZEROTHADMINMOPDB1 = "/aadb"
SlashCmdList.AZEROTHADMINMOPDB = function(msg)
  if frame:IsShown() then frame:Hide() else AAM:ShowDataBrowser() end
end

function AAM:ShowDataBrowser(kind, favoritesOnly)
  if kindExists[kind] then currentKind = kind end
  currentFavoritesOnly = currentKind == "Teleports" and favoritesOnly and true or false
  search:SetText("")
  pageOffset = 0
  frame:Show()
  render()
end
