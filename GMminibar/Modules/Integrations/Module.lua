local A = AzerothAdminMoP548
function A:OpenIntegrationsWindow()
    local frame=self.windows.integrations
    if not frame then
        frame=self.UI:CreateWindow("integrations",self:L("INTEGRATIONS"),600,390)
        local info=self.ReleaseSourceInfo; local counts=info.counts
        local text={
            self:L("STATIC_VERIFIED"),
            self:L("DATA_ONLY_NOTE"),
            "",
            "UI: "..info.ui_reference,
            "UI commit: "..info.ui_reference_commit,
            "Server: "..info.server_repository.." / "..info.server_branch,
            "Server baseline: "..info.server_baseline,
            "World DB: "..info.world_database_archive,
            "BlueItemInfo3 SHA256: "..info.blue_item_info_sha256,
            "InvenCraftInfo2 SHA256: "..info.inven_craft_info_sha256,
            "",
            "Items: "..counts.item_sources.." · Professions: "..counts.professions.." · Teleports: "..counts.mop_teleports,
            self:L("PLAYERBOT_BLOCKED"),
        }
        local body=self.UI:Text(frame,table.concat(text,"\n"),"small"); body:SetPoint("TOPLEFT",frame,"TOPLEFT",16,-55); body:SetWidth(560); body:SetHeight(310); body:SetJustifyH("LEFT"); body:SetJustifyV("TOP")
    end
    self.UI:ShowWindow(frame)
end
