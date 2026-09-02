local A = AzerothAdminMoP
A.UI = A.UI or {}

function A.UI:Label(parent, text, x, y, width)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x or 0, y or 0)
    if width then
        label:SetWidth(width)
        label:SetJustifyH("LEFT")
    end
    label:SetText(text or "")
    return label
end

function A.UI:Button(parent, text, x, y, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x or 0, y or 0)
    button:SetSize(width or 120, 24)
    button:SetText(text or "")
    if onClick then
        button:SetScript("OnClick", onClick)
    end
    return button
end

function A.UI:EditBox(parent, x, y, width)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", x or 0, y or 0)
    box:SetSize(width or 300, 24)
    box:SetAutoFocus(false)
    box:SetTextInsets(4, 4, 0, 0)
    return box
end
