local A = AzerothAdminMoP

-- MoP V2 command catalog. Security levels mirror the server's AccountTypes
-- ordering observed in cs_gm.cpp (GM=6, developer=7, administrator=8).
local S = A.Security
local function C(id, command, security, source, notes)
    A:RegisterCommand(id, command, security, source, notes)
end

C("gm_on", ".gm on", S.GAMEMASTER, "cs_gm.cpp")
C("gm_off", ".gm off", S.GAMEMASTER, "cs_gm.cpp")
C("gm_fly_on", ".gm fly on", S.GAMEMASTER, "cs_gm.cpp")
C("gm_fly_off", ".gm fly off", S.GAMEMASTER, "cs_gm.cpp")
C("gm_visible_on", ".gm visible on", S.GAMEMASTER, "cs_gm.cpp")
C("gm_visible_off", ".gm visible off", S.GAMEMASTER, "cs_gm.cpp")
C("tele", ".tele", S.GAMEMASTER, "cs_tele.cpp")
C("lookup_item", ".lookup item", S.GAMEMASTER, "cs_lookup.cpp")
C("lookup_creature", ".lookup creature", S.GAMEMASTER, "cs_lookup.cpp")
C("lookup_quest", ".lookup quest", S.GAMEMASTER, "cs_lookup.cpp")
C("additem", ".additem", S.GAMEMASTER, "cs_misc.cpp")
C("bank", ".bank", S.MODERATOR, "cs_misc.cpp")
C("revive", ".revive", S.GAMEMASTER, "cs_misc.cpp")
C("respawn", ".respawn", S.GAMEMASTER, "cs_misc.cpp")
C("repairitems", ".repairitems", S.GAMEMASTER, "cs_misc.cpp")
C("gps", ".gps", S.GAMEMASTER, "cs_misc.cpp")
C("recall", ".recall", S.GAMEMASTER, "cs_misc.cpp")
C("appear", ".appear", S.GAMEMASTER, "cs_misc.cpp")
C("summon", ".summon", S.GAMEMASTER, "cs_misc.cpp")
C("quest_add", ".quest add", S.ADMINISTRATOR, "cs_quest.cpp", "Requires selected player")
C("quest_complete", ".quest complete", S.ADMINISTRATOR, "cs_quest.cpp", "Requires selected player")
C("quest_remove", ".quest remove", S.ADMINISTRATOR, "cs_quest.cpp", "Requires selected player")
C("quest_reward", ".quest reward", S.ADMINISTRATOR, "cs_quest.cpp", "Requires selected player")

A.CommandMeta = {
    accountSecurity = {
        userReported = 6,
        gamemaster = S.GAMEMASTER,
        administrator = S.ADMINISTRATOR,
        note = "Level 6 permits SEC_GAMEMASTER commands; quest mutation commands are SEC_ADMINISTRATOR (8).",
    },
    sources = {
        gm = "src/server/scripts/Commands/cs_gm.cpp",
        misc = "src/server/scripts/Commands/cs_misc.cpp",
        quest = "src/server/scripts/Commands/cs_quest.cpp",
        tele = "src/server/scripts/Commands/cs_tele.cpp",
        lookup = "src/server/scripts/Commands/cs_lookup.cpp",
    },
    playerbot = {
        verified = false,
        blocked = true,
        reason = "Server POC boot/game gates are pending",
    },
}
