local A = AzerothAdminMoP548
A.Verification = A.Verification or {}
A.Verification.expected = {
    version = "1.0.0",
    interface = 50400,
    operatorSecurity = 9,
    security = { PLAYER = 0, MODERATOR = 1, GAMEMASTER = 2, ADMINISTRATOR = 3, CONSOLE = 4 },
    itemSources = 10974,
    professions = 11,
    quickTeleports = 793,
    databaseCatalog = 30,
    professionDetails = 5129,
    legacyCategoryEntries = 252,
    questLocations = 15794,
    teleportMeta = 793,
    generated = { Items = 80072, Quests = 18144, Creatures = 57526, Teleports = 793 },
}

function A:CollectStaticRuntimeFacts()
    local facts = {
        version = self.version,
        interface = self.interface,
        operatorSecurity = self.operatorSecurity,
        itemSources = self.Data and self.Data:CountItemSources() or 0,
        professions = self.Data and self.Data:CountProfessions() or 0,
        quickTeleports = self.Data and table.getn(self.Data.teleports or {}) or 0,
        databaseCatalog = self.Data and table.getn(self.Data.databaseCatalog or {}) or 0,
        professionDetails = self.Data and self.Data:CountTable(self.Data.professionDetails) or 0,
        legacyCategoryEntries = self.Data and self.Data.legacyItemCategories and table.getn(self.Data.legacyItemCategories.entries or {}) or 0,
        questLocations = self.Data and self.Data:CountQuestLocations() or 0,
        teleportMeta = self.Data and self.Data:CountTeleportMeta() or 0,
        commandCount = table.getn(self.CommandOrder or {}),
        moduleCount = table.getn(self.ModuleOrder or {}),
    }
    facts.generated = {}
    for kind in pairs(self.Verification.expected.generated) do
        facts.generated[kind] = self.Data and self.Data:GeneratedCount(kind) or 0
    end
    return facts
end
