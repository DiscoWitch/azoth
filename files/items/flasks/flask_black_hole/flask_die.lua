dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local x, y = self:transform()
local bh = Entity.Load("mods/azoth/files/items/flasks/flask_black_hole/black_hole.xml", x, y)
local mats = self.MaterialInventoryComponent.count_per_material_type
for k, v in ipairs(mats) do bh:setMaterialCount(k - 1, v) end
