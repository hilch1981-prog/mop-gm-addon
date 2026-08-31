AzerothAdminMoP = AzerothAdminMoP or {}
local AAM = AzerothAdminMoP

AAM.CommandGroups = {
  { key="general", label="General", commands={
    {"GM ON", ".gm on"}, {"GM OFF", ".gm off"}, {"Fly ON", ".gm fly on"}, {"Fly OFF", ".gm fly off"},
    {"Visible ON", ".gm visible on"}, {"Visible OFF", ".gm visible off"}, {"GM Chat ON", ".gm chat on"}, {"GM Chat OFF", ".gm chat off"},
    {"GM List", ".gm ingame"}, {"GPS", ".gps"}, {"Commands", ".commands"}, {"Save", ".save"}, {"Repair", ".repairitems"}, {"Bank", ".bank"},
  }},
  { key="cheats", label="Cheats", commands={
    {"God ON", ".cheat god on"}, {"God OFF", ".cheat god off"}, {"Power ON", ".cheat power on"}, {"Power OFF", ".cheat power off"},
    {"Cooldown ON", ".cheat cooldown on"}, {"Cooldown OFF", ".cheat cooldown off"}, {"Casttime ON", ".cheat casttime on"}, {"Casttime OFF", ".cheat casttime off"},
    {"Waterwalk ON", ".cheat waterwalk on"}, {"Waterwalk OFF", ".cheat waterwalk off"}, {"Explore ON", ".cheat explore on"}, {"Explore OFF", ".cheat explore off"},
    {"Taxi ON", ".cheat taxi on"}, {"Taxi OFF", ".cheat taxi off"}, {"Cheat status", ".cheat status"},
  }},
  { key="player", label="Player", commands={
    {"Appear", ".appear %s", "player"}, {"Summon", ".summon %s", "player"}, {"Recall", ".recall %s", "player (optional)"},
    {"Revive", ".revive %s", "player (optional)"}, {"Freeze", ".freeze %s", "player [seconds]"}, {"Unfreeze", ".unfreeze %s", "player"},
    {"PInfo", ".pinfo %s", "player"}, {"Combat stop", ".combatstop %s", "player"}, {"Level up", ".levelup %s", "levels"},
    {"Character level", ".character level %s", "level"}, {"Rename", ".character rename %s", "player"}, {"Customize", ".character customize %s", "player"},
  }},
  { key="modify", label="Modify", commands={
    {"Money", ".modify money %s", "copper"}, {"HP", ".modify hp %s", "hp"}, {"Mana", ".modify mana %s", "mana"},
    {"Rage", ".modify rage %s", "rage"}, {"Energy", ".modify energy %s", "energy"}, {"Runic", ".modify runicpower %s", "amount"},
    {"Honor", ".modify honor %s", "amount"}, {"Phase", ".modify phase %s", "phaseMask"}, {"Scale", ".modify scale %s", "scale"},
    {"Currency", ".modify currency %s", "currencyId amount"}, {"Speed all", ".modify speed all %s", "rate"}, {"Speed fly", ".modify speed fly %s", "rate"},
    {"Morph", ".morph %s", "displayId"}, {"Demorph", ".demorph"},
  }},
  { key="spells", label="Spells", commands={
    {"Cast", ".cast %s", "spellId"}, {"Aura", ".aura %s", "spellId"}, {"Unaura", ".unaura %s", "spellId"},
    {"Cooldown one", ".cooldown %s", "spellId"}, {"Cooldown all", ".cooldown"}, {"Learn", ".learn %s", "spellId"},
    {"Learn all ranks", ".learn %s all", "spellId"}, {"Unlearn", ".unlearn %s", "spellId"}, {"Class spells", ".learn all my spells"},
    {"Class + talents", ".learn all my class"}, {"All talents", ".learn all my talents"}, {"All recipes", ".learn all recipes %s", "profession (optional)"}, {"Max skill", ".maxskill"},
  }},
  { key="items", label="Items", commands={
    {"Add item", ".additem %s", "itemId [count]"}, {"Remove item", ".removeitem %s", "itemId [count]"}, {"Add item set", ".additemset %s", "itemSetId"},
    {"Lookup item", ".lookup item %s", "name"}, {"Lookup itemset", ".lookup itemset %s", "name"},
  }},
  { key="lookup", label="Lookup", commands={
    {"Area", ".lookup area %s", "text"}, {"Creature", ".lookup creature %s", "text"}, {"Quest", ".lookup quest %s", "text"},
    {"Spell", ".lookup spell %s", "text"}, {"Skill", ".lookup skill %s", "text"}, {"Teleport", ".lookup tele %s", "text"}, {"Map", ".lookup map %s", "text"},
  }},
  { key="teleport", label="Teleport", commands={
    {"Tele", ".tele %s", "location"}, {"Tele player", ".tele name %s", "player location"}, {"Go creature", ".go creature %s", "guid / id entry"},
    {"Go object", ".go object %s", "guid"}, {"Go XYZ", ".go xyz %s", "x y z [map]"}, {"Recall", ".recall"},
  }},
  { key="quest", label="Quest", commands={
    {"Lookup quest", ".lookup quest %s", "text"}, {"Add", ".quest add %s", "questId"}, {"Complete", ".quest complete %s", "questId"},
    {"Reward", ".quest reward %s", "questId"}, {"Remove", ".quest remove %s", "questId"},
  }},
  { key="npc", label="NPC", commands={
    {"Lookup creature", ".lookup creature %s", "name"}, {"NPC info", ".npc info"}, {"NPC near", ".npc near %s", "distance"},
    {"NPC add", ".npc add %s", "entry"}, {"NPC delete", ".npc delete"}, {"NPC move", ".npc move"},
    {"Set level", ".npc set level %s", "level"}, {"Set faction", ".npc set factionid %s", "factionId"}, {"Set model", ".npc set model %s", "displayId"},
    {"Respawn", ".respawn"},
  }},
  { key="server", label="Server", commands={
    {"Save all", ".saveall"}, {"Server info", ".server info"}, {"Server uptime", ".server uptime"}, {"Server motd", ".server motd"},
    {"Reload all", ".reload all"},
  }},
}

function AAM:GetGroup(key)
  for _, group in ipairs(self.CommandGroups) do if group.key == key then return group end end
end

function AAM:BuildCommand(entry, argument)
  local format = entry[2]
  if not string.find(format, "%%s", 1, true) then return format end
  argument = (argument or ""):match("^%s*(.-)%s*$")
  if argument == "" then return nil, entry[3] or "argument required" end
  return string.format(format, argument)
end
