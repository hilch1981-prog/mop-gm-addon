local A = AzerothAdminMoP

A:RegisterPanel("creatures", "TAB_CREATURES", 40, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("CREATURE_TITLE"), 16, -16)
    UI:Label(panel, A:L("LOOKUP_TEXT"), 16, -48)
    local input = UI:EditBox(panel, 16, -72, 330)
    UI:Button(panel, A:L("SEARCH"), 356, -72, 100, function()
        local text = input:GetText() or ""
        if text ~= "" then A:RunRegisteredCommand("lookup_creature", text) end
    end)
    UI:Label(panel, A:L("CREATURE_NOTE"), 16, -116, 430)
end)
