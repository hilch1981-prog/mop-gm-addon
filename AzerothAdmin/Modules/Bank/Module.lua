local A = AzerothAdminMoP

A:RegisterPanel("bank", "TAB_BANK", 70, function(panel)
    local UI = A.UI
    UI:Label(panel, A:L("BANK_TITLE"), 16, -16, 420)
    UI:Label(panel, A:L("BANK_MOP_NOTE"), 16, -48, 430)
    UI:Button(panel, A:L("BANK_OPEN"), 16, -88, 140, function()
        A:RunRegisteredCommand("bank")
    end)
    UI:Button(panel, A:L("BANK_CLOSE"), 166, -88, 140, function()
        if BankFrame and BankFrame:IsShown() then
            if HideUIPanel then HideUIPanel(BankFrame) else BankFrame:Hide() end
        end
    end)
end)
