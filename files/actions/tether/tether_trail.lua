dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local knot1 = self.var_int.knot1
local knot2 = self.var_int.knot2

if knot1 and knot2 and EntityGetIsAlive(knot1) and EntityGetIsAlive(knot2) then
    -- Zip back and forth along the rope to draw a trail along it
    local x1, y1, angle = EntityGetTransform(knot1)
    local x2, y2 = EntityGetTransform(knot2)
    self:setTransform(x1, y1, angle)
    self.ParticleEmitterComponent.mExPosition = {
        x = x2,
        y = y2
    }
else
    -- If either side of the tether is destroyed, destroy the tether effect too
    self:kill()
end
