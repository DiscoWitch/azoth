dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity.Current()
local mats = self.MaterialInventoryComponent.count_per_material_type
local stone = self:parent()
for k, v in ipairs(mats) do
    if v > 0 then
        stone.var_int.material = k - 1
        stone.var_int.color = GameGetPotionColorUint(self:id())
    end
end
