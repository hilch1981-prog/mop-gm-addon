local ADDON_NAME = ...

AzerothAdminMoP = AzerothAdminMoP or {}
local AAM = AzerothAdminMoP

AAM.version = "0.1.0-alpha"
AAM.commands = {
    { label = "GM ON", command = ".gm on" },
    { label = "GM OFF", command = ".gm off" },
    { label = "FLY ON", command = ".gm fly on" },
    { label = "FLY OFF", command = ".gm fly off" },
}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, name)
    if event ~= "ADDON_LOADED" or name ~= ADDON_NAME then
        return
    end

    AzerothAdminMoPDB = AzerothAdminMoPDB or {}
    AzerothAdminMoPDB.point = AzerothAdminMoPDB.point or "CENTER"
    AzerothAdminMoPDB.relativePoint = AzerothAdminMoPDB.relativePoint or "CENTER"
    AzerothAdminMoPDB.x = AzerothAdminMoPDB.x or 0
    AzerothAdminMoPDB.y = AzerothAdminMoPDB.y or 0
end)

function AAM:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aAzerothAdmin MoP:|r " .. tostring(message))
end

function AAM:SendCommand(command)
    if type(command) ~= "string" or command == "" then
        return
    end

    SendChatMessage(command, "SAY")
    self:Print("sent: " .. command)
end

function AAM:ResetPosition()
    if not AzerothAdminMoPFrame then
        return
    end

    AzerothAdminMoPFrame:ClearAllPoints()
    AzerothAdminMoPFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    AzerothAdminMoPDB.point = "CENTER"
    AzerothAdminMoPDB.relativePoint = "CENTER"
    AzerothAdminMoPDB.x = 0
    AzerothAdminMoPDB.y = 0
end

SLASH_AZEROTHADMINMOP1 = "/aamop"
SlashCmdList.AZEROTHADMINMOP = function(msg)
    msg = string.lower((msg or ""):match("^%s*(.-)%s*$"))

    if msg == "show" then
        AzerothAdminMoPFrame:Show()
    elseif msg == "hide" then
        AzerothAdminMoPFrame:Hide()
    elseif msg == "reset" then
        AAM:ResetPosition()
        AAM:Print("panel position reset")
    elseif msg == "help" then
        AAM:Print("/aamop - toggle panel")
        AAM:Print("/aamop show | hide | reset | help")
    else
        if AzerothAdminMoPFrame:IsShown() then
            AzerothAdminMoPFrame:Hide()
        else
            AzerothAdminMoPFrame:Show()
        end
    end
end
