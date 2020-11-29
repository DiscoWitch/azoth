dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local x, y = self:transform()
local storage = Entity.GetInRadius(x, y, 1)
storage = storage and storage:search(function(ent) return ent:name() == "larpa_storage" end)
if not storage then return end
self.var_str.larpa_data = storage.var_str.larpa_data
self.VelocityComponent.mVelocity = {x = storage.var_float.vx, y = storage.var_float.vy}
storage:kill()
