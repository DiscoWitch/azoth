dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity.Current()
local user = self:root()
local controls = user and user.ControlsComponent
if controls and controls.mButtonDownThrow and not controls.mButtonDownFire then
    local mic = self.MaterialSuckerComponent
    if mic.mAmountUsed < mic.barrel_size then
        local x, y = self:transform()
        local aimvec = controls.mAimingVectorNormalized
        local angle = math.atan2(aimvec.y, aimvec.x)
        local spread_deg = 15
        angle = angle + (math.random() - 0.5) * spread_deg * math.pi / 180
        local speed = 800
        shoot_projectile(self:id(), "mods/azoth/files/items/flasks/flask_vacuum_projectile.xml", x,
                         y, speed * math.cos(angle), speed * math.sin(angle), true)
    end
end
