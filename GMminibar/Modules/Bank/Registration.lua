local A = AzerothAdminMoP548
A:RegisterModule("bank", { status = "module-active-static-verified-game-test-pending", dependencies = { "commands" }, runtimeFiles = { "Modules/Bank/Module.lua", "Modules/Bank/Registration.lua" }, tests = { "tests/test_release_contract.py", "tools/verify_release.py" }, notes = "MoP 5.4.8 Build 18414 in-game smoke pending" })
