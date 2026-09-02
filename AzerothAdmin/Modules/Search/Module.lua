local A = AzerothAdminMoP

A:RegisterPanel("search", "TAB_SEARCH", 30, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("TAB_SEARCH"), 16, -16)
    UI:Label(panel, A:L("LOOKUP_TEXT"), 16, -52)

    local input = UI:EditBox(panel, 16, -76, 350)

    local function run(kind)
        local value = input:GetText() or ""
        if value ~= "" then
            A:SendCommand(".lookup " .. kind .. " " .. value)
        end
    end

    UI:Button(panel, A:L("ITEM"), 16, -116, 120, function() run("item") end)
    UI:Button(panel, A:L("CREATURE"), 146, -116, 120, function() run("creature") end)
    UI:Button(panel, A:L("QUEST"), 276, -116, 120, function() run("quest") end)

    UI:Label(panel, "Verified server family: .lookup", 16, -160, 450)
end)
