dofile_once("mods/azoth/files/lib/goki_variables.lua")
local self = GetUpdatedEntityID()

local x, y = EntityGetTransform(self)

local detector = EntityLoad("mods/azoth/files/items/palestone/palestone_projectile.xml", x, y)
EntityAddChild(self, detector)
local mat = EntityGetVariableNumber(self, "material", nil)
if mat ~= nil then
    local ic = EntityGetFirstComponentIncludingDisabled(self, "ItemComponent")
    ComponentSetValue2(ic, "ui_description", CellFactory_GetName(mat))

    for k, v in ipairs(EntityGetComponent(self, "ParticleEmitterComponent")) do
        local color = EntityGetVariableNumber(self, "color", 0xFFFFFFFF)
        ComponentSetValue2(v, "color", color)
    end

    for k, v in ipairs(EntityGetInRadiusWithTag(x, y, 100, "enemy")) do
        EntityAddRandomStains(v, mat, 10)
    end
end
