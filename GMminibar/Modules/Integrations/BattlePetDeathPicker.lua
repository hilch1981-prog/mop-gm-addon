-- Embedded from the user-supplied BattlePetDeathPicker 1.0 for MoP 5.4.8.
-- Hidden runtime helper only: no menu, no button, no SavedVariables, no slash command.
-- Scope intentionally limited to reopening the built-in pet selection frame when the active ally pet dies.
local ALLY = LE_BATTLE_PET_ALLY or 1
local watcher = CreateFrame("Frame")
AzerothAdminMoP548.BattlePetDeathPicker = { watcher=watcher }
local elapsedSinceDeath = 0
local retryWindow = 0
local retryTick = 0

local function CountLivingPets()
    local living = 0
    local petCount = C_PetBattles.GetNumPets(ALLY) or 0

    for petIndex = 1, petCount do
        local health = C_PetBattles.GetHealth(ALLY, petIndex)
        if health and health > 0 then
            living = living + 1
        end
    end

    return living
end

local function RefreshBattlePetButtons()
    if PetBattleFrame_UpdateActionBarLayout then
        PetBattleFrame_UpdateActionBarLayout(PetBattleFrame)
    end

    if PetBattleFrame_UpdateAllActionButtons then
        PetBattleFrame_UpdateAllActionButtons(PetBattleFrame)
    end
end

local function ShowDeathPetPicker()
    if not C_PetBattles or type(C_PetBattles.GetActivePet)~="function" or type(C_PetBattles.GetHealth)~="function" or type(C_PetBattles.GetNumPets)~="function" or not PetBattleFrame or
       not PetBattleFrame.BottomFrame or
       not PetBattleFrame.BottomFrame.PetSelectionFrame or
       type(PetBattlePetSelectionFrame_Show) ~= "function" then
        return false
    end

    if type(C_PetBattles.IsInBattle)=="function" and not C_PetBattles.IsInBattle() then return false end

    local activePet = tonumber(C_PetBattles.GetActivePet(ALLY))
    if not activePet or activePet<1 then
        return false
    end

    local activeHealth = C_PetBattles.GetHealth(ALLY, activePet)
    if activeHealth and activeHealth <= 0 and CountLivingPets() >= 1 then
        RefreshBattlePetButtons()
        local picker = PetBattleFrame.BottomFrame.PetSelectionFrame
        if not picker:IsShown() then
            PetBattlePetSelectionFrame_Show(picker)
        end
        return true
    end

    return false
end

local function BeginDeathCheck()
    elapsedSinceDeath = 0
    retryWindow = 2.0
    retryTick = 0

    watcher:SetScript("OnUpdate", function(self, elapsed)
        elapsedSinceDeath = elapsedSinceDeath + elapsed
        retryTick = retryTick + elapsed

        if retryTick >= 0.05 then
            retryTick = 0
            ShowDeathPetPicker()
        end

        if elapsedSinceDeath >= retryWindow then
            self:SetScript("OnUpdate", nil)
        end
    end)
end

watcher:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
watcher:RegisterEvent("PET_BATTLE_HEALTH_CHANGED")
watcher:RegisterEvent("PET_BATTLE_CLOSE")
watcher:RegisterEvent("PET_BATTLE_OVER")
watcher:SetScript("OnEvent", function(_, event, owner, petIndex)
    if event=="PET_BATTLE_CLOSE" or event=="PET_BATTLE_OVER" then watcher:SetScript("OnUpdate",nil);return end
    if event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" then
        BeginDeathCheck()
        return
    end

    petIndex=tonumber(petIndex)
    if event == "PET_BATTLE_HEALTH_CHANGED" and owner == ALLY and petIndex and petIndex>=1 and C_PetBattles and type(C_PetBattles.GetHealth)=="function" then
        local health = C_PetBattles.GetHealth(owner, petIndex)
        if health and health <= 0 then
            BeginDeathCheck()
        end
    end
end)
