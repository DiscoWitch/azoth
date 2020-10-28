dofile_once("mods/azoth/files/lib/goki_variables.lua")

local self = GetUpdatedEntityID()
local parent = EntityGetRootEntity(self)

-- Make sure we're getting the right parent
if parent == self then
    return
end

local stain_rate = EntityGetVariableNumber(self, "stain_rate", -1)
if stain_rate == -1 then
    stain_rate = 20
end

-- Logic to reduce stain_rate
local fire = GameGetGameEffect(parent, "ON_FIRE")
local oiled = GameGetGameEffect(parent, "OILED")
if (fire ~= 0 or oiled ~= 0) and stain_rate > 0 then
    stain_rate = stain_rate - 1
    print(tostring(stain_rate))
    if stain_rate == 0 then
        EntityKill(self)
    end
    EntitySetVariableNumber(self, "stain_rate", stain_rate)
end

-- Reapply ichor to prevent washing it off easily
local ichor = CellFactory_GetType("magic_liquid_ichor")
EntityAddRandomStains(parent, ichor, stain_rate)

