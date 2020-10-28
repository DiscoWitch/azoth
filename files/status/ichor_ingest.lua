local self = GetUpdatedEntityID()
local parent = EntityGetRootEntity(self)

-- Make sure we're getting the right parent
if parent == self then
    return
end

-- Ichor effects
local ichor = CellFactory_GetType("magic_liquid_ichor")
EntityAddRandomStains(parent, ichor, 20)

