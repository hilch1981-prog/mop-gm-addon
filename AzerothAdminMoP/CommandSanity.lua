local AAM = AzerothAdminMoP

-- Keep the UI catalog strict to MOP_V2_Repack. The target core exposes uptime
-- through `.server info`; it has no standalone `.server uptime` subcommand.
for _, group in ipairs(AAM.CommandGroups or {}) do
  if group.key == "server" then
    for index = #group.commands, 1, -1 do
      if group.commands[index][2] == ".server uptime" then
        table.remove(group.commands, index)
      end
    end
  end
end
