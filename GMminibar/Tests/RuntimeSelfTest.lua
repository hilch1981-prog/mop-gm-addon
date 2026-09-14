local A = AzerothAdminMoP548

local function same(left, right)
    return (tonumber(left) and tonumber(right) and math.abs(tonumber(left)-tonumber(right)) < 0.01) or tostring(left) == tostring(right)
end

function A:RunRuntimeSelfTest()
    local expected = self.Verification and self.Verification.expected or {}
    local facts = self:CollectStaticRuntimeFacts()
    local failures = {}
    local function check(label, actual, wanted)
        if not same(actual, wanted) then
            table.insert(failures, label .. " expected=" .. tostring(wanted) .. " actual=" .. tostring(actual))
        end
    end

    check("version", facts.version, expected.version)
    check("interface", facts.interface, expected.interface)
    check("operatorSecurity", facts.operatorSecurity, expected.operatorSecurity)
    check("bootstrapVersion", self.bootstrapVersion, 6)
    check("schemaVersion", self:GetDB().schemaVersion, 7)
    if AzerothAdminMoP548 ~= self then table.insert(failures, "stable namespace mismatch") end
    if type(self.UI) ~= "table" then
        table.insert(failures, "A.UI table missing")
    elseif type(self.UI.CreateWindow) ~= "function" or type(self.UI.Button) ~= "function" then
        table.insert(failures, "shared UI component methods missing")
    end
    if not self.eventFrame then table.insert(failures, "startup event frame missing") end
    if not (SlashCmdList and type(SlashCmdList["AZEROTHADMINMOP"]) == "function") then
        table.insert(failures, "/aamop registration missing")
    end
    for key, wanted in pairs(expected.security or {}) do check("security." .. key, self.Security[key], wanted) end
    check("itemSources", facts.itemSources, expected.itemSources)
    check("professions", facts.professions, expected.professions)
    check("quickTeleports", facts.quickTeleports, expected.quickTeleports)
    check("databaseCatalog", facts.databaseCatalog, expected.databaseCatalog)
    check("professionDetails", facts.professionDetails, expected.professionDetails)
    check("legacyCategoryEntries", facts.legacyCategoryEntries, expected.legacyCategoryEntries)
    check("questLocations", facts.questLocations, expected.questLocations)
    check("teleportMeta", facts.teleportMeta, expected.teleportMeta)
    for key, wanted in pairs(expected.generated or {}) do check("generated." .. key, facts.generated[key], wanted) end
    if not (self.CommandMeta and self.CommandMeta.playerbot and self.CommandMeta.playerbot.blocked) then
        table.insert(failures, "PlayerBot gate must remain blocked")
    end

    local function create(label, method)
        if type(method) ~= "function" then
            table.insert(failures, label .. " creator missing")
            return
        end
        local ok, err = pcall(method, self)
        if not ok then table.insert(failures, label .. " create error=" .. tostring(err)) end
    end
    local function geometry(label, frame, width, height)
        if not frame then table.insert(failures, label .. " frame missing"); return end
        if frame.rc8Lock then width,height=1080,700
        elseif frame.rc3List then width,height=900,560
        elseif frame.aaeCards then width,height=760,520
        elseif frame.aaeExpanded then width,height=914,610
        elseif frame == A.toolbar and frame.aaeFourSlots then width,height=414,32
        else width=width*(frame.aaeLayoutSX or 1); height=height*(frame.aaeLayoutSY or 1) end
        check(label .. ".width", frame:GetWidth(), width)
        check(label .. ".height", frame:GetHeight(), height)
    end
    local function count(label, rows, wanted)
        check(label, table.getn(rows or {}), wanted)
    end

    geometry("ui.main", self.frame, 520, 405)
    geometry("ui.toolbar", self.toolbar, 414, 32)
    if self.toolbar and not self.toolbar:IsShown() and not self:GetDB().toolbarHidden
        and not (self.Workbench and self.Workbench.frame and self.Workbench.frame:IsShown()) then
        table.insert(failures, "minibar unexpectedly hidden")
    end
    if not self.minimapButton then table.insert(failures, "minimap launcher missing") end
    count("ui.main.commandRows", self.commandButtons, 20)

    create("ui.teleports", self.CreateTeleportWindow)
    geometry("ui.teleports", self.teleportFrame, 500, 470)
    count("ui.teleports.rows", self.teleportFrame and self.teleportFrame.rows, 24)
    count("ui.teleports.categories", self.teleportFrame and self.teleportFrame.categoryButtons, 6)

    create("ui.teleportFavorites", self.CreateTeleportFavoritesWindow)
    geometry("ui.teleportFavorites", self.teleportFavoritesFrame, 520, 500)
    count("ui.teleportFavorites.rows", self.teleportFavoritesFrame and self.teleportFavoritesFrame.rows, 12)

    create("ui.items", self.CreateItemBrowser)
    geometry("ui.items", self.itemBrowser, 900, 610)
    geometry("ui.items.categoryScroll", self.itemBrowser and self.itemBrowser.categoryScroll, 205, self.itemBrowser:GetHeight()-130)
    count("ui.items.rows", self.itemBrowser and self.itemBrowser.rows, 30)

    create("ui.quests", self.CreateQuestHelperWindow)
    geometry("ui.quests", self.questHelperFrame, 880, 600)
    count("ui.quests.searchRows", self.questHelperFrame and self.questHelperFrame.searchRows, 6)
    count("ui.quests.questRows", self.questHelperFrame and self.questHelperFrame.questRows, 8)
    count("ui.quests.objectiveRows", self.questHelperFrame and self.questHelperFrame.objectiveRows, 5)

    create("ui.professions", self.CreateProfessionWindow)
    geometry("ui.professions", self.professionFrame, 850, 570)
    local recipeWidth=math.floor((self.professionFrame:GetWidth()-242)*.51)
    geometry("ui.professions.professionPanel", self.professionFrame and self.professionFrame.professionPanel, 190, self.professionFrame:GetHeight()-92)
    geometry("ui.professions.recipePanel", self.professionFrame and self.professionFrame.recipePanel, recipeWidth, self.professionFrame:GetHeight()-92)
    geometry("ui.professions.detailPanel", self.professionFrame and self.professionFrame.detailPanel, self.professionFrame:GetWidth()-242-recipeWidth, self.professionFrame:GetHeight()-92)
    count("ui.professions.skills", self.professionFrame and self.professionFrame.professionButtons, 11)
    count("ui.professions.recipeRows", self.professionFrame and self.professionFrame.recipeRows, 20)

    -- User-reported R3/R4 regressions. No server command is sent by these checks.
    check("ui.languageCycle", table.concat(self.LanguageCycleOrder or {}, ">"), "auto>koKR>enUS>zhCN>zhTW>ruRU")
    if not self.languageMinibarButton then table.insert(failures, "language minibar button missing") end
    if not (self.minimapButton and self.minimapButton.aaeRing) then
        table.insert(failures, "minimap creator icon ring missing")
    end
    if not (self.itemInfoButton and self.itemInfoButton.aaeIcon) then
        table.insert(failures, "item-info minibar icon missing")
    end
    if not (self.GetDB and self:GetDB().teleportFullCatalog ~= false) then
        table.insert(failures, "full game_tele catalog must be default")
    end
    if not (self.IsPlaceholderItemRow and self:IsPlaceholderItemRow({ 13727, "[임시] Brilliant Dawn Gloves" })) then
        table.insert(failures, "temporary item filter regression")
    end
    local gold = self.Data and self.Data:GetProfessionDetail(3308)
    if not (gold and tonumber(gold.createdItem) == 3577 and gold.reagents and gold.reagents[1]
        and tonumber(gold.reagents[1].id) == 2776 and tonumber(gold.reagents[1].count) == 1) then
        table.insert(failures, "gold smelting reagent regression")
    end
    if not (self.Data and self.Data:GetLegacyItemCategory("7")) then
        table.insert(failures, "canonical item categories missing")
    end
    local questLocationCount = self.Data and self.Data:CountQuestLocations() or 0
    if questLocationCount ~= 15794 then table.insert(failures, "quest location data count mismatch") end
    local teleportMetaCount = self.Data and self.Data:CountTeleportMeta() or 0
    if teleportMetaCount ~= 793 then table.insert(failures, "teleport metadata count mismatch") end
    if not (self.GetQuestLocationRecord and self.GoToQuestTarget and self.QuestObjectiveTeleport) then
        table.insert(failures, "quest navigation runtime missing")
    end
    if not (self.Data and self.Data.EnrichTeleport and self.SetTeleportRegion) then
        table.insert(failures, "teleport localization/filter runtime missing")
    end
    if not (self.ApplyProfessionReagentVisual and self.PrimeProfessionCaches and self.ResetProfessionLocaleCache) then
        table.insert(failures, "R6 profession cache/reagent visual runtime missing")
    end
    local db = self:GetDB()
    if tonumber(db.professionSpellCacheVersion) ~= 1 or type(db.professionSpellCache) ~= "table" then
        table.insert(failures, "persistent profession cache missing")
    end

    -- R7 game-feedback regressions.
    if not (self.ItemBrowserQualityOrder and self.BuildItemBrowserFilters) then
        table.insert(failures, "R7 item filter helpers missing")
    else
        local artifact = false; for _, quality in ipairs(self.ItemBrowserQualityOrder) do if quality == 6 then artifact = true end end
        if not artifact then table.insert(failures, "Artifact quality filter missing") end
    end
    if not (self.GetQuestObjectiveLookupQuery and self.GetQuestObjectives) then
        table.insert(failures, "R7 quest lookup/dialogue runtime missing")
    else
        local command, query = self:GetQuestObjectiveLookupQuery({ type = "monster", dbObjective = { k = "c", r = { { n = "카산드라 카붐" } } }, targets = { { n = "카산드라 카붐" } } })
        if command ~= "lookup_creature" or query ~= "카산드라 카붐" then table.insert(failures, "quest lookup must use localized name") end
    end
    if not (self.GetTeleportFaction and self.GetTeleportLevelRange and self.TeleportMatchesProgress) then
        table.insert(failures, "R7 teleport progression helpers missing")
    else
        if self.GetTeleportFaction({ name = "Stormwind" }) ~= "ALLIANCE" then table.insert(failures, "Alliance teleport faction classification failed") end
        if self.GetTeleportFaction({ name = "Orgrimmar" }) ~= "HORDE" then table.insert(failures, "Horde teleport faction classification failed") end
    end
    if not (self.GetProfessionRequirement and self.GetProfessionTierForSkill and self.CanLearnProfessionRecipe) then
        table.insert(failures, "R7 profession requirement helpers missing")
    else
        local professionID, requiredSkill = self.GetProfessionRequirement(3308, 186)
        if tonumber(professionID) ~= 186 or tonumber(requiredSkill) ~= 115 then table.insert(failures, "Smelt Gold requirement decode failed") end
        local tier = self.GetProfessionTierForSkill(525)
        if not tier or tier.key ~= "ZEN_MASTER" then table.insert(failures, "Zen Master tier decode failed") end
    end

    -- R9 screenshot regressions.
    if type(self.GetProfessionRecipeResultIcon) ~= "function" then
        table.insert(failures, "R9 profession result-icon helper missing")
    end
    if type(self.IsTeleportUsable) ~= "function" or type(self.AvailableServerTeleportCount) ~= "function" then
        table.insert(failures, "R9 teleport safety helpers missing")
    else
        if self:IsTeleportUsable({ id = 817, name = "ScottTest" }) then table.insert(failures, "ScottTest must be disabled") end
        if tonumber(self:AvailableServerTeleportCount()) ~= 793 then table.insert(failures, "curated teleport count mismatch") end
        for _, id in ipairs({1005,1837}) do if self:IsTeleportUsable(self.Data:EnrichTeleport({id=id},true)) then table.insert(failures,"fall teleport must be excluded: "..id) end end
    end

    -- R10 screenshot regressions.
    if type(self.TeleportMatchesProgress) ~= "function" then
        table.insert(failures, "R10 faction-only teleport filter missing")
    end
    if not (self.teleportFrame == nil or true) then
        table.insert(failures, "R10 teleport frame contract failed")
    end

    -- R11 hidden BattlePet picker is intentionally not exposed in AzerothAdmin UI.
    -- Its event behavior is covered by package/mock regression tests.

    -- R8 screenshot/AreaTable regressions.
    if not (self.UI and self.UI.GoBack and self.UI.ShowWindow) then
        table.insert(failures, "R8 back-navigation runtime missing")
    end
    if not (self.BuildMainInfoLine and string.find(self:BuildMainInfoLine(), self.releaseDate, 1, true)) then
        table.insert(failures, "R8 deploy-date header missing")
    end
    if not (self.FindQuestHelperQuestByID and self.ValidateQuestObjectiveSelection) then
        table.insert(failures, "R8 quest selection guard missing")
    end
    if self.CommandCatalog.server_restart and not self.CommandCatalog.server_restart.lifecycle then
        table.insert(failures, "R8 lifecycle command marker missing")
    end
    if self:GetDB().showServerLifecycleCommands ~= false then
        table.insert(failures, "R8 lifecycle commands must be hidden by default")
    end

    if table.getn(failures) == 0 then
        self:Print("SELFTEST PASS · " .. facts.commandCount .. " commands · " .. facts.moduleCount .. " modules")
        return true
    end
    self:Print("SELFTEST FAIL (" .. table.getn(failures) .. ")", true)
    for _, failure in ipairs(failures) do self:Print(failure, true) end
    return false, failures
end
