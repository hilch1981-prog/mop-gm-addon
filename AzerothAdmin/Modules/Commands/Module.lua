local A = AzerothAdminMoP

A:RegisterPanel("commands", "TAB_COMMANDS", 10, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("TAB_COMMANDS"), 16, -16)

    local commands = {
        { A:L("GM_ON"), ".gm on" },
        { A:L("GM_OFF"), ".gm off" },
        { A:L("FLY_ON"), ".gm fly on" },
        { A:L("FLY_OFF"), ".gm fly off" },
        { A:L("VISIBLE_ON"), ".gm visible on" },
        { A:L("VISIBLE_OFF"), ".gm visible off" },
    }

    for i, row in ipairs(commands) do
        local column = (i - 1) % 2
        local line = math.floor((i - 1) / 2)
        UI:Button(panel, row[1], 16 + column * 150, -48 - line * 32, 140, function()
            A:SendCommand(row[2])
        end)
    end

    UI:Label(panel, A:L("CUSTOM_COMMAND"), 16, -168)
    local input = UI:EditBox(panel, 16, -192, 350)
    input:SetText(".")
    UI:Button(panel, A:L("SEND"), 376, -192, 90, function()
        A:SendCommand(input:GetText())
    end)
end)
