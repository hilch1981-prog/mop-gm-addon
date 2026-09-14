local A = AzerothAdminMoP548
A.Data:RegisterItemSources(A.MoPItemSources or {}, {
    name = "BlueItemInfo3 5.4 fanfix3", interface = 50400,
    sha256 = A.ReleaseSourceInfo.blue_item_info_sha256,
})
A.Data:RegisterProfessions(A.MoPProfessions or {}, {
    name = "InvenCraftInfo2 v4.0", interface = 50400,
    sha256 = A.ReleaseSourceInfo.inven_craft_info_sha256,
})
A.Data:RegisterTeleports(A.MoPTeleports or {}, {
    name = "MOP_V2_Repack game_tele MoP subset",
    baseline = A.ReleaseSourceInfo.server_baseline,
})
A.Data:RegisterTeleportDbNames(A.MoPTeleportDbNames or {}, {
    name = "MOP_V2_Repack game_tele command names",
    baseline = A.ReleaseSourceInfo.server_baseline,
    count = 1602,
})
A.Data:RegisterTeleportMeta(A.MoPTeleportMeta or {}, {
    name = "User-supplied TeleportMeta.lua 2026-09-08; fall destinations excluded",
    baseline = A.ReleaseSourceInfo.server_baseline,
    count = 1602,
})
A.Data:RegisterQuestLocations(A.MoPQuestLocations or {}, {
    name = "MOP_V2_Repack quest relations, quest_objective and world spawns",
    baseline = A.ReleaseSourceInfo.server_baseline,
    quests = 15794,
    objectives = 17686,
    coordinateObjectives = 7637,
})
A.Data:RegisterDatabaseCatalog(A.MoPDatabaseCatalog or {}, {
    repository = A.ReleaseSourceInfo.server_repository,
    baseline = A.ReleaseSourceInfo.server_baseline,
})
A.Data:RegisterProfessionDetails(A.MoPProfessionDetails or {}, {
    source = "InvenCraftInfo2 v4.0 TOC metadata",
    interface = 50400,
    detailRecipes = 5129,
    reagentLinks = 11461,
})
A.Data:RegisterLegacyItemCategories(A.MoPLegacyItemCategories or { entries = {}, categories = {} }, {
    source = "AzerothAdmin_3.5.0-335a CategoryIndex",
    verifiedItemIDs = 16166,
    displayedEntries = 252,
})
