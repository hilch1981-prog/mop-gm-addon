local A = AzerothAdminMoP

A:RegisterPanel("quest_helper", "TAB_QUEST_HELPER", 50, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("QUEST_HELPER_TITLE"), 16, -16)
    UI:Label(panel, A:L("QUEST_ADMIN_WARNING"), 16, -44, 430)
    UI:Label(panel, A:L("QUEST_ID"), 16, -88)
    local input = UI:EditBox(panel, 16, -112, 180)

    local actions = {
        { A:L("QUEST_ADD"), "quest_add" },
        { A:L("QUEST_COMPLETE"), "quest_complete" },
        { A:L("QUEST_REMOVE"), "quest_remove" },
        { A:L("QUEST_REWARD"), "quest_reward" },
    }
    for i, row in ipairs(actions) do
        local x = 16 + ((i - 1) % 2) * 155
        local y = -154 - math.floor((i - 1) / 2) * 32
        UI:Button(panel, row[1], x, y, 145, function()
            local questID = input:GetText() or ""
            if questID ~= "" then A:RunRegisteredCommand(row[2], questID) end
        end)
    end

    UI:Button(panel, A:L("QUEST_LOOKUP"), 326, -112, 130, function()
        local questID = input:GetText() or ""
        if questID ~= "" then A:RunRegisteredCommand("lookup_quest", questID) end
    end)
end)
