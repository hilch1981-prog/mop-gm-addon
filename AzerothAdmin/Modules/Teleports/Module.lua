local A = AzerothAdminMoP

A:RegisterPanel("teleports", "TAB_TELEPORTS", 20, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("TAB_TELEPORTS"), 16, -16)
    UI:Label(panel, A:L("TELE_NAME"), 16, -48)
    local input = UI:EditBox(panel, 16, -72, 300)
    local resultButtons = {}

    local function run(name)
        if name and name ~= "" then A:RunRegisteredCommand("tele", name) end
    end

    UI:Button(panel, A:L("SEND"), 326, -72, 90, function() run(input:GetText()) end)
    UI:Button(panel, A:L("SEARCH"), 426, -72, 90, function()
        local needle = string.lower(input:GetText() or "")
        local matches = {}
        if needle ~= "" and A.Data and A.Data.Teleports then
            for _, row in ipairs(A.Data.Teleports) do
                local name = tostring(row[2] or "")
                if string.find(string.lower(name), needle, 1, true) then
                    table.insert(matches, row)
                    if #matches >= 8 then break end
                end
            end
        end
        for i, button in ipairs(resultButtons) do
            local row = matches[i]
            if row then
                button:SetText(row[2] .. " [map " .. tostring(row[3]) .. "]")
                button.teleName = row[2]
                button:Show()
            else
                button.teleName = nil
                button:Hide()
            end
        end
    end)

    for i = 1, 8 do
        local button = UI:Button(panel, "", 16, -112 - (i - 1) * 30, 500, function(self) run(self.teleName) end)
        button:Hide()
        resultButtons[i] = button
    end
end)
