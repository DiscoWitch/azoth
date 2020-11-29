dofile_once("mods/azoth/files/lib/disco_util.lua")

local now = GameGetFrameNum()
local self = Entity.Current()
local x, y, angle = self:transform()
local pbc = self.PhysicsBodyComponent
local vel = pbc:getVelocity()
local angvel = pbc:getAngularVelocity()

local drag = 0.5
local ang_drag = 0.1
local righting = 1
local target_angle = math.sin(now * math.pi / 200) * math.pi / 8
local fx = -drag * vel.x
local fy = -drag * vel.y
local torque = -righting * math.sin(angle - target_angle) - ang_drag * angvel

local ray_angle = math.atan2(vel.y, vel.x)
if vel.x ^ 2 + vel.y ^ 2 < 10 ^ 2 then ray_angle = math.pi / 2 end
ray_angle = ray_angle + (math.random() - 0.5) * math.pi / 8

local min_dist = 10
local max_dist = 30 + 5 * math.sin(now * math.pi / 60)
local x1 = x + min_dist * math.cos(ray_angle)
local y1 = y + min_dist * math.sin(ray_angle)
local x2 = x + max_dist * math.cos(ray_angle)
local y2 = y + max_dist * math.sin(ray_angle)
local did_hit, hit_x, hit_y = RaytraceSurfacesAndLiquiform(x1, y1, x2, y2)

if did_hit then
    local float_force = 10
    local hit_dist = math.sqrt((hit_x - x) ^ 2 + (hit_y - y) ^ 2)
    local t = (max_dist - hit_dist) / (max_dist - min_dist)
    local lerp = 0 * (1 - t) + 1 * t
    fx = fx - float_force * (hit_x - x) / hit_dist * lerp
    fy = fy - float_force * (hit_y - y) / hit_dist * lerp
end
self:applyForce(fx, fy)
self:applyTorque(torque)

