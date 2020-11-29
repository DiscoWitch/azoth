dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()

local detect_range = 20

function GetClosest(x, y, tags)
    local target = false
    local target_dist = false
    for i = 1, #tags do
        local closest = Entity(EntityGetClosestWithTag(x, y, tags[i]))
        if closest then
            local cx, cy = closest:transform()
            local dist = (cx - x) ^ 2 + (cy - y) ^ 2
            if not target or dist < target_dist then
                target = closest
                target_dist = dist
            end
        end
    end
    return target, target_dist
end

local x, y = self:transform()
local ents = Entity.GetInRadius(x, y, detect_range)
local active = ents and ents:search(function(ent) return ent:name() == "leash_knot" end)
if active then
    -- Don't re-leash things that are already leashed
    return
end
-- Search for the closest tetherable thing
local target, tdist = GetClosest(x, y, {"prop_physics", "item_physics", "tablet"})
if target and tdist < detect_range ^ 2 then
    -- Found an object that can be tethered
    target:addGameEffect("mods/azoth/files/actions/leash/leash_knot.xml")
    return
end
