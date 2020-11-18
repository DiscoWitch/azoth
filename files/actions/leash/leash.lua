dofile_once("mods/azoth/files/lib/disco_util.lua")
local self = Entity(GetUpdatedEntityID())
local knot = Entity(self.var_int.knot)
local handle = Entity(self.var_int.owner)

if not knot or not handle or not knot:alive() or not handle:alive() then
    self:kill()
    return
end
if knot:parent():id() ~= knot:root():id() then
    knot:kill()
    return
end

-- Tether settings
local dist_max = self.var_float.dist_max or 50
local dist_snap = self.var_float.dist_snap or 250
local pull_force = 1 * dist_max
local drag = 0.05

local x1, y1, angle = knot:transform()
local x2, y2 = handle:transform()
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

    local v1 = {
        x = (x1 - (knot.var_float.prev_x or x1)) * 60,
        y = (y1 - (knot.var_float.prev_y or y1)) * 60
    }
    knot:parent():applyForce(fx - drag * v1.x, fy - drag * v1.y)
end
knot.var_float.prev_x = x1
knot.var_float.prev_y = y1
handle.var_float.prev_x = x2
handle.var_float.prev_y = y2

-- Zip back and forth along the rope to draw a trail along it
self:setTransform(x1, y1, angle)
self.ParticleEmitterComponent.mExPosition = {
    x = x2,
    y = y2
}
