AzerothAdminMoP = AzerothAdminMoP or {}
local A = AzerothAdminMoP

A.name = "AzerothAdmin"
A.version = "0.1.0-mop-alpha"
A.interface = 50400
A.panels = A.panels or {}
A.panelOrder = A.panelOrder or {}

function A:RegisterPanel(key, titleKey, order, builder)
    self.panels[key] = {
        key = key,
        titleKey = titleKey,
        order = order or 100,
        builder = builder,
    }

    for _, value in ipairs(self.panelOrder) do
        if value == key then
            return
        end
    end

    table.insert(self.panelOrder, key)
end

function A:SendCommand(command)
    if not command or command == "" then
        return
    end

    if string.sub(command, 1, 1) ~= "." then
        command = "." .. command
    end

    SendChatMessage(command, "SAY")
end

function A:Print(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aAzerothAdmin MoP:|r " .. tostring(message))
    end
end

SLASH_AZEROTHADMINMOP1 = "/aamop"
SlashCmdList["AZEROTHADMINMOP"] = function(message)
    message = message or ""
    if message ~= "" then
        A:SendCommand(message)
        return
    end

    if A.Toggle then
        A:Toggle()
    else
        A:Print("UI is not ready.")
    end
end
