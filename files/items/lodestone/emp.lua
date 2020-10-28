local self = GetUpdatedEntityID()
local x, y = EntityGetTransform(self)

local robots = EntityGetInRadiusWithTag(x, y, 100, "robot")
for k, v in ipairs(robots) do
    EntityInflictDamage(v, 1 / 25, "DAMAGE_ELECTRICITY", "EMP stun", "NONE", 0, 0)
end
