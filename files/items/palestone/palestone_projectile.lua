dofile_once("mods/azoth/files/lib/goki_variables.lua")

local self = GetUpdatedEntityID();
local mic = EntityGetFirstComponent(self, "MaterialInventoryComponent")
local mats = ComponentGetValue2(mic, "count_per_material_type")
for k, v in ipairs(mats) do
    if v > 0 then
        EntitySetVariableNumber(EntityGetParent(self), "material", k - 1)
        EntitySetVariableNumber(EntityGetParent(self), "color", GameGetPotionColorUint(self))

    end
end
