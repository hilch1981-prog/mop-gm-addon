local A = AzerothAdminMoP

A:RegisterPanel("language", "TAB_LANGUAGE", 5, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("LANGUAGE_TITLE"), 16, -16, 420)
    UI:Label(panel, A:L("LANGUAGE_CURRENT") .. ": " .. tostring(GetLocale and GetLocale() or "enUS"), 16, -48, 420)
    UI:Label(panel, A:L("LANGUAGE_FALLBACK"), 16, -76, 420)
end)
