local dist = 300
local self = GetUpdatedEntityID()
local x, y, angle = EntityGetTransform(self)
-- Get the spread angle of the wand (it's the total arc that the spread can cover, not cone angle)
local wand = EntityGetParent(self)
local wand_ac = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
local scatter = ComponentObjectGetValue2(wand_ac, "gunaction_config", "spread_degrees")
scatter = math.max(scatter, 0)
-- spread angle is in degrees, code angles are in radians
-- Draw the bottom laser on even frames, top laser on odd frames
-- We just set the angle that the laser comes out at by adding/subtracting half of the spread angle
angle = angle + (GameGetFrameNum() % 2 - 0.5) * scatter * math.pi / 180
-- Find the closest solid that the laser could hit
local did_hit, hit_x, hit_y = Raytrace(x, y, x + dist * math.cos(angle), y + dist * math.sin(angle))
if not did_hit then
    -- If no solid is found, make it go to the maximum distance
    hit_x = x + dist * math.cos(angle)
    hit_y = y + dist * math.sin(angle)
end
-- Compute the length of the laser for figuring out how many particles we need
-- to keep the intensity constant
local hit_dist = math.sqrt((hit_x - x) ^ 2 + (hit_y - y) ^ 2)
-- Trail hax: Set "where this emitter was last frame" to the target location to draw a trail from there
local laser = EntityGetFirstComponent(self, "ParticleEmitterComponent", "laser")
ComponentSetValue2(laser, "mExPosition", hit_x, hit_y)
if scatter > 0 then
    -- If we're drawing two beams, double our particle count to compensate
    -- for the toggling between the two beams
    -- We set different min/max lengths because trails like to make particles
    -- perfectly evenly distributed when min=max, causing artifacts
    ComponentSetValue2(laser, "count_min", hit_dist / 2)
    ComponentSetValue2(laser, "count_max", hit_dist)
else
    ComponentSetValue2(laser, "count_min", hit_dist / 4)
    ComponentSetValue2(laser, "count_max", hit_dist / 2)
end
local cone = EntityGetFirstComponent(self, "ParticleEmitterComponent", "cone_fill")
ComponentSetValue2(cone, "count_min", scatter * hit_dist ^ 2 / 10000)
ComponentSetValue2(cone, "count_max", scatter * hit_dist ^ 2 / 10000)
ComponentSetValue2(cone, "area_circle_radius", 0, hit_dist)
ComponentSetValue2(cone, "area_circle_sector_degrees", scatter)

