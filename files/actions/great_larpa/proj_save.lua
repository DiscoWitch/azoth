dofile_once("mods/azoth/files/lib/disco_util.lua")
dofile_once("mods/azoth/files/lib/polysave/polysave.lua")

local self = Entity(GetUpdatedEntityID())
if not self.var_int.larpa_data then
    local x, y = GameGetCameraPos()
    self.var_int.larpa_data = EntityLoad("mods/azoth/files/actions/great_larpa/storage.xml", x, y)
end
local data = Entity(self.var_int.larpa_data)
if data and data:alive() then
    self:setParent(data)
else
    print("Larpa data was killed by its CameraBoundComponent")
    return
end
if not data.var_str.projdata then
    local vel = self.VelocityComponent.mVelocity
    data.var_float.vx = vel.x
    data.var_float.vy = vel.y
    polysave(self, data:id(), "projdata")
end
