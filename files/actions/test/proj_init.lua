dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local x, y = self:transform()
local nearby = Entity.GetInRadius(x, y, 10)
local host = nearby and nearby:search(function(ent) return ent:name() == "larpa_host" end)
if host then self:setParent(host) end
