dofile_once("mods/azoth/files/lib/disco_util.lua")
local polytools = dofile_once("mods/azoth/files/lib/polytools/polytools.lua")

local self = Entity.Current()
if not self.var_str.larpa_data then
    local owner = Entity(self.ProjectileComponent.mWhoShot)
    if not owner then return end
    local children = owner:children()
    local culler = children and children:search(function(ent) return ent:name() == "larpa_cull" end)
    if not culler then owner:addGameEffect("mods/azoth/files/actions/larpa/larpa_cull.xml") end
    local x, y = self:transform()
    local storage = Entity.GetInRadius(x, y, 1)
    storage = storage and storage:search(function(ent) return ent:name() == "larpa_storage" end)
    if not storage then
        local vel = self.VelocityComponent.mVelocity
        storage = Entity(EntityCreateNew("larpa_storage"))
        storage:setTransform(x, y)
        storage.var_float.vx = vel.x
        storage.var_float.vy = vel.y
        storage.var_str.larpa_data = polytools.save(self)
    end
end
