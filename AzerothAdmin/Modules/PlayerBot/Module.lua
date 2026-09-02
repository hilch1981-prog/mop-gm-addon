local A = AzerothAdminMoP

A:RegisterPanel("playerbot", "TAB_PLAYERBOT", 40, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("TAB_PLAYERBOT"), 16, -16)
    UI:Label(panel, A:L("PLAYERBOT_BLOCKED"), 16, -52, 460)

    local button = UI:Button(panel, "PlayerBot V2 - POC", 16, -118, 200, nil)
    button:Disable()
end)
