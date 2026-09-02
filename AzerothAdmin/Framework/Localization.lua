local A = AzerothAdminMoP
A.locales = A.locales or {}

function A:RegisterLocale(locale, values)
    self.locales[locale] = values
end

function A:L(key)
    local locale = GetLocale and GetLocale() or "enUS"
    local selected = self.locales[locale] or self.locales.enUS or {}
    local fallback = self.locales.enUS or {}
    return selected[key] or fallback[key] or key
end
