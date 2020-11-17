dofile_once("mods/azoth/files/lib/disco_util.lua")
dofile_once("mods/azoth/files/lib/polysave/polysave.lua")

local self = Entity(GetUpdatedEntityID())
if not self.var_int.larpa_data then
    return
end
local data = Entity(self.var_int.larpa_data)
if data and data:alive() then
    self:setParent(data)
else
    return
end
if data.var_str.projdata then
    -- Only if the projectile has been saved
    local vx = data.var_float.vx
    local vy = data.var_float.vy
    if vx and vy then
        self.VelocityComponent.mVelocity = {
            x = vx,
            y = vy
        }
    end
end
