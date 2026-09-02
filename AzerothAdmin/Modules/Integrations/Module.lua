local A = AzerothAdminMoP

A:RegisterPanel("integrations", "TAB_INTEGRATIONS", 90, function(panel)
    local UI = A.UI
    local itemCount = A.Data and A.Data.Items and #A.Data.Items or 0
    local questCount = A.Data and A.Data.Quests and #A.Data.Quests or 0
    local creatureCount = A.Data and A.Data.Creatures and #A.Data.Creatures or 0
    local teleCount = A.Data and A.Data.Teleports and #A.Data.Teleports or 0
    local professionCount = A.Data and A.Data:CountProfessions() or 0
    UI:Label(panel, A:L("INTEGRATIONS_TITLE"), 16, -16)
    UI:Label(panel, "MOP_V2_Repack / repack-main", 16, -48, 430)
    UI:Label(panel, "SQL: items " .. itemCount .. " / quests " .. questCount .. " / creatures " .. creatureCount .. " / teleports " .. teleCount, 16, -76, 500)
    UI:Label(panel, A:L("DATA_PROFESSIONS") .. ": " .. professionCount .. "/11", 16, -104, 430)
    UI:Label(panel, A:L("PLAYERBOT_BLOCKED"), 16, -142, 480)
end)
