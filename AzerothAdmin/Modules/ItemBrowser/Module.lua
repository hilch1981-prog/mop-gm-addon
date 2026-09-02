local A = AzerothAdminMoP

local itemIndex
local function ensureIndex()
    if itemIndex then return itemIndex end
    itemIndex = {}
    if A.Data and A.Data.Items then
        for _, row in ipairs(A.Data.Items) do
            itemIndex[tonumber(row[1])] = row
        end
    end
    return itemIndex
end

local function formatSource(raw)
    if not raw or raw == "" then return nil end
    return raw:gsub("@@", " / "):gsub("_", " ")
end

local function describeItem(id)
    local row = ensureIndex()[id]
    if not row then return nil end
    return string.format("[%d] %s | Q:%s iLv:%s Req:%s", row[1] or id, row[2] or "?", row[3] or 0, row[4] or 0, row[5] or 0)
end

A:RegisterPanel("item_browser", "TAB_ITEM_BROWSER", 45, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("ITEM_BROWSER_TITLE"), 16, -16)
    UI:Label(panel, A:L("ITEM_ID"), 16, -48)
    local itemID = UI:EditBox(panel, 16, -72, 150)
    UI:Label(panel, A:L("QUANTITY"), 176, -48)
    local quantity = UI:EditBox(panel, 176, -72, 60)
    quantity:SetText("1")
    local result = UI:Label(panel, A:L("ITEM_SOURCE_READY"), 16, -150, 450)

    UI:Button(panel, A:L("ITEM_SOURCE"), 246, -72, 100, function()
        local id = tonumber(itemID:GetText())
        if not id then result:SetText(A:L("INVALID_ID")); return end
        local base = describeItem(id) or ("[" .. id .. "] " .. A:L("ITEM_SOURCE_MISSING"))
        local source = A.Data and A.Data:GetItemSource(id)
        if source then base = base .. "\n" .. A:L("ITEM_SOURCE") .. ": " .. formatSource(source) end
        result:SetText(base)
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
