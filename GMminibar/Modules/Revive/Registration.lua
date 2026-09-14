local A = AzerothAdminMoP548
A:RegisterModule("revive", { status = "module-active-static-verified-game-test-pending", dependencies = { "commands" }, runtimeFiles = { "Modules/Revive/Module.lua", "Modules/Revive/Registration.lua" }, tests = { "tests/test_release_contract.py", "tools/verify_release.py" }, notes = "MoP 5.4.8 Build 18414 in-game smoke pending" })
