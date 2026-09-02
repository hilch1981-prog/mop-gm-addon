local A = AzerothAdminMoP

A.CommandMeta = {
    gm = {
        verified = true,
        source = "src/server/scripts/Commands/cs_gm.cpp",
        examples = {
            ".gm on",
            ".gm off",
            ".gm fly on",
            ".gm fly off",
            ".gm visible on",
            ".gm visible off",
        },
    },
    tele = {
        verified = true,
        source = "src/server/scripts/Commands/cs_tele.cpp",
    },
    lookup = {
        verified = true,
        source = "src/server/scripts/Commands/cs_lookup.cpp",
    },
    playerbot = {
        verified = false,
        blocked = true,
        reason = "Server POC boot/game gates are pending",
    },
}
