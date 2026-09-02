local A = AzerothAdminMoP

A:RegisterPanel("search", "TAB_SEARCH", 30, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("TAB_SEARCH"), 16, -16)
    UI:Label(panel, A:L("LOOKUP_TEXT"), 16, -48)
    local input = UI:EditBox(panel, 16, -72, 300)
    local kind = "Items"
    local rows = {}
    local resultButtons = {}

    local function refresh()
        rows = A:SearchData(kind, input:GetText(), 8, 0)
        for i, button in ipairs(resultButtons) do
            local row = rows[i]
            if row then
                button:SetText(A:DescribeDataRow(kind, row))
                button.dataRow = row
                button:Show()
            else
                button.dataRow = nil
                button:Hide()
            end
        end
    end

    local kinds = { {"Items", A:L("ITEM")}, {"Creatures", A:L("CREATURE")}, {"Quests", A:L("QUEST")} }
    for i, entry in ipairs(kinds) do
        UI:Button(panel, entry[2], 326 + (i - 1) * 72, -72, 68, function()
            kind = entry[1]
            refresh()
        end)
    end

    UI:Button(panel, A:L("SEARCH"), 16, -104, 100, refresh)
    for i = 1, 8 do
        local button = UI:Button(panel, "", 16, -142 - (i - 1) * 30, 500, function(self)
            if self.dataRow then A:DataAction(kind, self.dataRow) end
        end)
        button:Hide()
        resultButtons[i] = button
    end
end)
