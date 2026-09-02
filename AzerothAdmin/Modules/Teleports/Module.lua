local A = AzerothAdminMoP

A:RegisterPanel("teleports", "TAB_TELEPORTS", 20, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("TAB_TELEPORTS"), 16, -16)
    UI:Label(panel, A:L("TELE_NAME"), 16, -52)

    local input = UI:EditBox(panel, 16, -76, 350)
    UI:Button(panel, A:L("SEND"), 376, -76, 90, function()
        local value = input:GetText() or ""
        if value ~= "" then
            A:SendCommand(".tele " .. value)
        end
    end)

    UI:Label(panel, "Verified server family: .tele", 16, -120, 450)
end)
