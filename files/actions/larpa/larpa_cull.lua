dofile_once("mods/azoth/files/lib/disco_util.lua")

local range = 300
local max_count = 10

local self = Entity.Current()
local x, y = self:transform()
local larpas = Entity.GetInRadius(x, y, range)
larpas = larpas and larpas:search(function(ent) return ent.var_str.larpa_data end)
if not larpas or larpas:len() <= max_count then return end
local count = larpas:len()
larpas:sort(function(a, b)
    local xa, ya = a:transform()
    local xb, yb = b:transform()
    local dist_a = (xa - x) ^ 2 + (ya - y) ^ 2
    local dist_b = (xb - x) ^ 2 + (yb - y) ^ 2
    return dist_a > dist_b
end)
for i = 1, (count - max_count) do larpas[i].var_bool.larpa_stop = true end
