local AAM = AzerothAdminMoP
AAM.Data = AAM.Data or {}

local function lower(value)
  return string.lower(tostring(value or ""))
end

function AAM:SearchData(kind, query, limit)
  local source = self.Data and self.Data[kind]
  if type(source) ~= "table" then return {} end
  query = lower((query or ""):match("^%s*(.-)%s*$"))
  limit = tonumber(limit) or 50
  local numeric = tonumber(query)
  local out = {}
  for _, row in ipairs(source) do
    local id = tonumber(row[1]) or 0
    local name = tostring(row[2] or "")
    if query == "" or (numeric and id == numeric) or string.find(lower(name), query, 1, true) then
      out[#out + 1] = row
      if #out >= limit then break end
    end
  end
  return out
end

function AAM:DataAction(kind, row)
  if not row then return end
  local id = tonumber(row[1]) or 0
  if kind == "Items" then
    self:SendCommand(".additem " .. id)
  elseif kind == "Quests" then
    self:SendCommand(".quest add " .. id)
  elseif kind == "Creatures" then
    self:SendCommand(".go creature id " .. id)
  elseif kind == "Teleports" then
    local name = tostring(row[2] or "")
    if name ~= "" then self:SendCommand(".tele " .. name) end
  end
end

function AAM:DescribeDataRow(kind, row)
  if kind == "Items" then
    return string.format("[%d] %s  iLv:%s Req:%s Q:%s", row[1] or 0, row[2] or "", row[4] or 0, row[5] or 0, row[3] or 0)
  elseif kind == "Quests" then
    return string.format("[%d] %s  Lv:%s Min:%s Zone:%s", row[1] or 0, row[2] or "", row[3] or 0, row[4] or 0, row[5] or 0)
  elseif kind == "Creatures" then
    return string.format("[%d] %s  Lv:%s-%s Rank:%s", row[1] or 0, row[2] or "", row[3] or 0, row[4] or 0, row[5] or 0)
  elseif kind == "Teleports" then
    return string.format("[%d] %s  Map:%s (%.1f, %.1f, %.1f)", row[1] or 0, row[2] or "", row[3] or 0, tonumber(row[4]) or 0, tonumber(row[5]) or 0, tonumber(row[6]) or 0)
  end
  return tostring(row[2] or row[1] or "")
end
