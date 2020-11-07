dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = GetUpdatedEntityID()

local parent = Entity(EntityGetParent(self))
if not parent then
    return
end
-- Multiply incoming damage
for k, v in parent.HitboxComponent:ipairs() do
    v.damage_multiplier = v.damage_multiplier * 5
end
