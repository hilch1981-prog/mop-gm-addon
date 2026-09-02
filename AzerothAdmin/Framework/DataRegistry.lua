local A = AzerothAdminMoP

A.Data = A.Data or {
    itemSources = {},
    professions = {},
    provenance = {},
}

function A.Data:RegisterItemSources(values, provenance)
    if type(values) ~= "table" then return end
    for itemID, source in pairs(values) do
        if type(itemID) == "number" and type(source) == "string" then
            self.itemSources[itemID] = source
        end
    end
    if provenance then self.provenance.items = provenance end
end

function A.Data:RegisterProfessions(values, provenance)
    if type(values) ~= "table" then return end
    for professionID, info in pairs(values) do
        if type(professionID) == "number" and type(info) == "table" then
            self.professions[professionID] = info
        end
    end
    if provenance then self.provenance.professions = provenance end
end

function A.Data:GetItemSource(itemID)
    return self.itemSources[tonumber(itemID)]
end

function A.Data:GetProfession(professionID)
    return self.professions[tonumber(professionID)]
end

function A.Data:CountItems()
    local count = 0
    for _ in pairs(self.itemSources) do count = count + 1 end
    return count
end

function A.Data:CountProfessions()
    local count = 0
    for _ in pairs(self.professions) do count = count + 1 end
    return count
end
