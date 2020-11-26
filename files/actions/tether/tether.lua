dofile_once("mods/azoth/files/lib/disco_util.lua")
local self = Entity.Current()
local k1 = Entity(self.var_int.knot1)
local k2 = Entity(self.var_int.knot2)

if not k1 or not k2 or not k1:alive() or not k2:alive() then
    self:kill()
    return
end
if not k1:parent() or k1:parent():id() ~= k1:root():id() then
    k1:kill()
    return
end
if not k2:parent() or k2:parent():id() ~= k2:root():id() then
    k2:kill()
    return
end

-- Tether settings
local dist_max = self.var_float.dist_max or 50
local dist_snap = self.var_float.dist_snap or 250
local pull_force = 1 * dist_max
local drag = 0.05

local x1, y1, angle = k1:transform()
local x2, y2 = k2:transform()
local dist_x = x1 - x2
local dist_y = y1 - y2
local dist = math.sqrt(dist_x ^ 2 + dist_y ^ 2)
if dist > dist_snap then
    -- Snap the tether
    self:kill()
    return
end

if dist > dist_max then
    local ang = math.atan2(dist_y, dist_x)
    local fr = -pull_force * (dist / dist_max - 1)
    local fx = fr * math.cos(ang)
    local fy = fr * math.sin(ang)

    local v1 = {x = (x1 - (k1.var_float.prev_x or x1)) * 60,
                y = (y1 - (k1.var_float.prev_y or y1)) * 60}
    local v2 = {x = (x2 - (k2.var_float.prev_x or x2)) * 60,
                y = (y2 - (k2.var_float.prev_y or y2)) * 60}

    k1:parent():applyForce(fx - drag * v1.x, fy - drag * v1.y)
    k2:parent():applyForce(-fx - drag * v2.x, -fy - drag * v2.y)
end
k1.var_float.prev_x = x1
k1.var_float.prev_y = y1
k2.var_float.prev_x = x2
k2.var_float.prev_y = y2

-- Zip back and forth along the rope to draw a trail along it
self:setTransform(x1, y1, angle)
self.ParticleEmitterComponent.mExPosition = {x = x2, y = y2}
