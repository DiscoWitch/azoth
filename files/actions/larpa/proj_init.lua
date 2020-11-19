dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local x, y = self:transform()
local storage = Entity.getInRadius(x, y, 1)
storage = storage and storage:search(function(ent)
    return ent:name() == "larpa_storage"
end)
if not storage then
    return
end
self.var_str.larpa_data = storage.var_str.larpa_data
self.VelocityComponent.mVelocity = {
    x = storage.var_float.vx,
    y = storage.var_float.vy
}
storage:kill()
