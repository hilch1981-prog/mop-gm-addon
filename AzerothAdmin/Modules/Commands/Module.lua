local A = AzerothAdminMoP

A:RegisterPanel("commands", "TAB_COMMANDS", 10, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("TAB_COMMANDS") .. " - " .. A:L("GM_LEVEL_6"), 16, -16)

    local commands = {
        { A:L("GM_ON"), "gm_on" }, { A:L("GM_OFF"), "gm_off" },
        { A:L("FLY_ON"), "gm_fly_on" }, { A:L("FLY_OFF"), "gm_fly_off" },
        { A:L("VISIBLE_ON"), "gm_visible_on" }, { A:L("VISIBLE_OFF"), "gm_visible_off" },
        { A:L("GPS"), "gps" }, { A:L("RECALL"), "recall" },
    }
    for i, row in ipairs(commands) do
        local column = (i - 1) % 2
        local line = math.floor((i - 1) / 2)
        UI:Button(panel, row[1], 16 + column * 150, -48 - line * 30, 140, function()
            A:RunRegisteredCommand(row[2])
        end)
    end

    UI:Label(panel, A:L("PLAYER_NAME"), 316, -48)
    local player = UI:EditBox(panel, 316, -72, 140)
    UI:Button(panel, A:L("APPEAR"), 316, -104, 65, function()
        if player:GetText() ~= "" then A:RunRegisteredCommand("appear", player:GetText()) end
    end)
    UI:Button(panel, A:L("SUMMON"), 391, -104, 65, function()
        if player:GetText() ~= "" then A:RunRegisteredCommand("summon", player:GetText()) end
    end)

    UI:Label(panel, A:L("CUSTOM_COMMAND"), 16, -184)
    local input = UI:EditBox(panel, 16, -208, 350)
    input:SetText(".")
    UI:Button(panel, A:L("SEND"), 376, -208, 80, function() A:SendCommand(input:GetText()) end)
    UI:Label(panel, A:L("QUEST_ADMIN_WARNING"), 16, -248, 440)
end)
