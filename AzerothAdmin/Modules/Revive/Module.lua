local A = AzerothAdminMoP

A:RegisterPanel("revive", "TAB_REVIVE", 75, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("REVIVE_TITLE"), 16, -16)
    UI:Label(panel, A:L("REVIVE_NOTE"), 16, -48, 430)
    UI:Button(panel, A:L("REVIVE"), 16, -88, 130, function() A:RunRegisteredCommand("revive") end)
    UI:Button(panel, A:L("RESPAWN"), 156, -88, 130, function() A:RunRegisteredCommand("respawn") end)
    UI:Button(panel, A:L("REPAIR"), 296, -88, 130, function() A:RunRegisteredCommand("repairitems") end)
end)
