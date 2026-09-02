local A = AzerothAdminMoP

A.Security = {
    PLAYER = 0,
    MODERATOR = 3,
    BANMASTER = 4,
    EVENTMASTER = 5,
    GAMEMASTER = 6,
    DEVELOPER = 7,
    ADMINISTRATOR = 8,
}

A.CommandCatalog = A.CommandCatalog or {}

function A:RegisterCommand(id, command, security, source, notes)
    self.CommandCatalog[id] = {
        id = id,
        command = command,
        security = security,
        source = source,
        notes = notes,
    }
end

function A:GetCommand(id)
    return self.CommandCatalog[id]
end

function A:RunRegisteredCommand(id, suffix)
    local info = self.CommandCatalog[id]
    if not info then
        self:Print("Unknown command: " .. tostring(id))
        return false
    end
    local command = info.command
    if suffix and suffix ~= "" then command = command .. " " .. suffix end
    self:SendCommand(command)
    return true
end
