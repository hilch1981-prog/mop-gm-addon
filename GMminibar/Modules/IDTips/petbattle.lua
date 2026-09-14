-- Adapted from user supplied nidtip5, Silverwind / nidtip5 rebuild.
local A=AzerothAdminMoP548
local function safeHook(target,method,callback)
 if type(target)=='string' then if type(_G[target])=='function' then hooksecurefunc(target,method) end
 elseif target and type(target[method])=='function' then hooksecurefunc(target,method,callback) end
end
local labels = GMminibarNidtip.labels
local addLine = GMminibarNidtip.addLine

---@param tooltip table
---@param id string|number|nil
local function addAbilityIdToPetTooltip(tooltip, id)
  -- Append pet battle ability IDs to Pandaria pet battle tooltips.
  if not tooltip or not id then return end
  if tooltip.AddDoubleLine then
    addLine(tooltip, id, labels.ability)
    return
  end

  local description = tooltip.Description
  if not description or not description.GetText or not description.SetText then return end

  local text = description:GetText() or ""
  if text:find(labels.ability, 1, true) then return end
  description:SetText(text .. "\r\r" .. labels.ability .. "|cffffffff " .. id .. "|r")
  A:ApplyLocaleFont(description)
end

---@param button table
local function onPetBattleAbilityButtonEnter(button)
  -- Add ability IDs when hovering Pandaria pet battle ability buttons.
  if not C_PetBattles or not LE_BATTLE_PET_ALLY or not button or button:GetEffectiveAlpha() <= 0 then return end

  local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY)
  local id = select(1, C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, petIndex, button:GetID()))
  addAbilityIdToPetTooltip(PetBattlePrimaryAbilityTooltip, id)
end

---@param aura table
local function onPetBattleAuraEnter(aura)
  -- Add ability IDs when hovering Pandaria pet battle auras.
  if not C_PetBattles or not aura then return end

  local parent = aura:GetParent()
  if not parent then return end

  local id = select(1, C_PetBattles.GetAuraInfo(parent.petOwner, parent.petIndex, aura.auraIndex))
  addAbilityIdToPetTooltip(PetBattlePrimaryAbilityTooltip, id)
end

local function hookPetBattleMethods()
  -- Register Pandaria pet battle hooks when the client exposes them.
  if PetBattleAbilityButton_OnEnter and not GMminibarNidtip_PET_BATTLE_BUTTON_HOOKED then
    safeHook("PetBattleAbilityButton_OnEnter", onPetBattleAbilityButtonEnter)
    GMminibarNidtip_PET_BATTLE_BUTTON_HOOKED = true
  end
  if PetBattleAura_OnEnter and not GMminibarNidtip_PET_BATTLE_AURA_HOOKED then
    safeHook("PetBattleAura_OnEnter", onPetBattleAuraEnter)
    GMminibarNidtip_PET_BATTLE_AURA_HOOKED = true
  end
end

hookPetBattleMethods()

local loader=CreateFrame("Frame");loader:RegisterEvent("ADDON_LOADED");loader:SetScript("OnEvent",hookPetBattleMethods)
