local A = AzerothAdminMoP

local function formatSource(raw)
    if not raw or raw == "" then return nil end
    return raw:gsub("@@", " / "):gsub("_", " ")
end

A:RegisterPanel("item_browser", "TAB_ITEM_BROWSER", 45, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("ITEM_BROWSER_TITLE"), 16, -16)
    UI:Label(panel, A:L("ITEM_ID"), 16, -48)
    local itemID = UI:EditBox(panel, 16, -72, 150)
    UI:Label(panel, A:L("QUANTITY"), 176, -48)
    local quantity = UI:EditBox(panel, 176, -72, 60)
    quantity:SetText("1")
    local result = UI:Label(panel, A:L("ITEM_SOURCE_READY"), 16, -150, 440)

    UI:Button(panel, A:L("ITEM_SOURCE"), 246, -72, 100, function()
        local id = tonumber(itemID:GetText())
        if not id then result:SetText(A:L("INVALID_ID")); return end
        local source = A.Data and A.Data:GetItemSource(id)
        result:SetText(source and (A:L("ITEM_SOURCE") .. ": " .. formatSource(source)) or A:L("ITEM_SOURCE_MISSING"))
    end)
    UI:Button(panel, A:L("ITEM_LOOKUP"), 356, -72, 100, function()
        local query = itemID:GetText() or ""
        if query ~= "" then A:RunRegisteredCommand("lookup_item", query) end
    end)
    UI:Button(panel, A:L("ADD_ITEM"), 16, -112, 130, function()
        local id = tonumber(itemID:GetText())
        local qty = tonumber(quantity:GetText()) or 1
        if not id then result:SetText(A:L("INVALID_ID")); return end
        A:RunRegisteredCommand("additem", tostring(id) .. " " .. tostring(math.max(1, math.floor(qty))))
    end)
end)
