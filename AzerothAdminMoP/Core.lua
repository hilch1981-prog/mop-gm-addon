local ADDON_NAME = ...

AzerothAdminMoP = AzerothAdminMoP or {}
local AAM = AzerothAdminMoP
AAM.version = "1.0.0-rc1"
AAM.history = AAM.history or {}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, name)
  if event ~= "ADDON_LOADED" or name ~= ADDON_NAME then return end
  AzerothAdminMoPDB = AzerothAdminMoPDB or {}
  local db = AzerothAdminMoPDB
  db.point = db.point or "CENTER"
  db.relativePoint = db.relativePoint or "CENTER"
  db.x = db.x or 0
  db.y = db.y or 0
  db.lastGroup = db.lastGroup or "general"
  db.history = db.history or {}
  AAM.history = db.history
end)

function AAM:Print(message)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aAzerothAdmin MoP:|r " .. tostring(message))
end

function AAM:SendCommand(command)
  command = type(command) == "string" and command:match("^%s*(.-)%s*$") or ""
  if command == "" then return false end
  if command:sub(1, 1) ~= "." then command = "." .. command end
  SendChatMessage(command, "SAY")
  table.insert(self.history, 1, command)
  while #self.history > 30 do table.remove(self.history) end
  if AzerothAdminMoPDB then AzerothAdminMoPDB.history = self.history end
  self:Print((self.L and self.L.sent or "Sent") .. ": " .. command)
  if self.RefreshHistory then self:RefreshHistory() end
  return true
end

function AAM:ResetPosition()
  local frame = AzerothAdminMoPFrame
  if not frame then return end
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  if AzerothAdminMoPDB then
    AzerothAdminMoPDB.point, AzerothAdminMoPDB.relativePoint = "CENTER", "CENTER"
    AzerothAdminMoPDB.x, AzerothAdminMoPDB.y = 0, 0
  end
end

SLASH_AZEROTHADMINMOP1 = "/aamop"
SLASH_AZEROTHADMINMOP2 = "/mopgm"
SlashCmdList.AZEROTHADMINMOP = function(msg)
  msg = (msg or ""):match("^%s*(.-)%s*$")
  local lower = string.lower(msg)
  if lower == "show" then AzerothAdminMoPFrame:Show()
  elseif lower == "hide" then AzerothAdminMoPFrame:Hide()
  elseif lower == "reset" then AAM:ResetPosition(); AAM:Print("panel position reset")
  elseif lower == "help" then
    AAM:Print("/aamop - toggle panel")
    AAM:Print("/aamop show | hide | reset | help")
    AAM:Print("/mopgm <.command> - send raw GM command")
  elseif msg ~= "" then AAM:SendCommand(msg)
  elseif AzerothAdminMoPFrame:IsShown() then AzerothAdminMoPFrame:Hide() else AzerothAdminMoPFrame:Show() end
end
