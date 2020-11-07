dofile_once("mods/azoth/files/lib/disco_util.lua")
local self = Entity(GetUpdatedEntityID())

local x, y = self:transform()

if not initialized then
    SetRandomSeed(x, y)
end

local detector = EntityLoad("mods/azoth/files/items/palestone/palestone_projectile.xml", x + Random(-5, 5),
                     y + Random(-5, 5))
EntityAddChild(self:id(), detector)
local mat = self.var_int.material
if mat then
    local color = self.var_int.color or 0xFFFFFFFF
    for k, v in self.ParticleEmitterComponent:ipairs() do
        v.color = color
    end
    for k, v in ipairs(EntityGetInRadiusWithTag(x, y, 100, "enemy")) do
        EntityAddRandomStains(v, mat, 10)
    end
end
