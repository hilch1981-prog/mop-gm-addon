local A = AzerothAdminMoP

local professionNames = {
    [129]="First Aid", [164]="Blacksmithing", [165]="Leatherworking", [171]="Alchemy",
    [185]="Cooking", [186]="Mining", [197]="Tailoring", [202]="Engineering",
    [333]="Enchanting", [755]="Jewelcrafting", [773]="Inscription",
}

local function countNode(node)
    local categories, recipes = 0, 0
    for _, entry in ipairs(node or {}) do
        if type(entry.list) == "table" then
            categories = categories + 1
            recipes = recipes + #entry.list
        end
        if type(entry.header) == "table" then
            local c, r = countNode(entry.header)
            categories = categories + c
            recipes = recipes + r
        end
    end
    return categories, recipes
end

A:RegisterPanel("profession_info", "TAB_PROFESSION_INFO", 55, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("PROFESSION_TITLE"), 16, -16)
    UI:Label(panel, A:L("PROFESSION_ID"), 16, -48)
    local professionID = UI:EditBox(panel, 16, -72, 160)
    local result = UI:Label(panel, A:L("PROFESSION_READY"), 16, -116, 430)

    UI:Button(panel, A:L("SHOW"), 186, -72, 110, function()
        local id = tonumber(professionID:GetText())
        if not id then result:SetText(A:L("INVALID_ID")); return end
        local info = (A.MoPProfessionIndex and A.MoPProfessionIndex[id]) or (A.Data and A.Data:GetProfession(id))
        if type(info) ~= "table" then result:SetText(A:L("PROFESSION_MISSING")); return end
        local categories, recipes = countNode(info)
        result:SetText((professionNames[id] or tostring(id)) .. ": " .. categories .. " " .. A:L("CATEGORIES") .. ", " .. recipes .. " " .. A:L("RECIPES"))
    end)

    UI:Label(panel, A:L("PROFESSION_IDS") .. ": 129, 164, 165, 171, 185, 186, 197, 202, 333, 755, 773", 16, -154, 430)
end)
