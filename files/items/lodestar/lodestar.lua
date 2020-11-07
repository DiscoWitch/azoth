dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())

local mass = self.VelocityComponent.mass
local g = 9.8 * 5
local antigrav = -g * mass
local drag = 10 * mass

local pbc = self.PhysicsBodyComponent
if not pbc then
    return
end
local vx, vy = pbc:getVelocity()
self:applyForce(-drag * vx, -drag * vy + antigrav)
local angvel = pbc:getAngularVelocity()
-- self:applyTorque(-angvel)
if angvel < 15 then
    self:applyTorque(mass * 2)
end
