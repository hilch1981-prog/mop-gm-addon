local A = AzerothAdminMoP

if A.MoPItemSources then
    A.Data:RegisterItemSources(A.MoPItemSources, {
        source = "BlueItemInfo3 5.4 fanfix3",
        interface = 50400,
    })
end

if A.MoPProfessionIndex then
    A.Data:RegisterProfessions(A.MoPProfessionIndex, {
        source = "InvenCraftInfo2 v4.0",
        interface = 50400,
    })
end
