dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local x, y = self:transform()

function BodyForce(entity, mass, bx, by, vx, vy, angvel)
    local fmax = -20 * mass
    local fmin = -12 * mass
    local t0 = self.var_int.start_time + 60
    local t1 = self.var_int.start_time + 180
    local lerp = (GameGetFrameNum() - t0) / (t1 - t0)
    local fx = bx ~= x and mass / (bx - x)
    local fy = fmax * (1 - lerp) + fmin * lerp
    local torque = 0
    return bx, by, fx, fy, torque
end

self.PhysicsBodyComponent.go_through_sand = true
local creature = Entity(self.var_int.creature)
if not creature then
    local x, y = self:transform()
    -- Assume that the entity that just died had a damagemodel component

    creature = Entity.getInRadius(x, y, 50):search(function(ent)
        return ent:name() == "polynull" and not ent.var_bool.necromancy_owned
    end)
    if not creature then
        return
    end
    creature.var_bool.necromancy_owned = true
    self.var_int.creature = creature:id()
    self.var_int.start_time = GameGetFrameNum()
elseif GameGetFrameNum() < self.var_int.start_time + 59 then
    -- wait a second before lifting the body
elseif GameGetFrameNum() < self.var_int.start_time + 60 then
    self.ParticleEmitterComponent:setEnabled(true)
elseif GameGetFrameNum() < self.var_int.start_time + 179 then
    PhysicsApplyForceOnArea(BodyForce, 0, x - 1, y - 1, x + 1, y + 1)
elseif GameGetFrameNum() < self.var_int.start_time + 180 then
    creature:setTransform(x, y, 0, 1, 1)
    self.MagicConvertMaterialComponent:setEnabled(true)
    if creature:children() then
        local effect = creature:children():search(function(ent)
            return ent:name() == "polyhide"
        end)
        if effect then
            effect.GameEffectComponent.frames = 5
        end
    end
end
