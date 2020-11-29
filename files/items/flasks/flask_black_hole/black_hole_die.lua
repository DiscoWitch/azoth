dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local x, y = self:transform()
local flask = Entity.Load("mods/azoth/files/items/flasks/flask_black_hole/flask.xml", x, y)
flask.DamageModelComponent.invincibility_frames = 30
local mats = self.MaterialInventoryComponent.count_per_material_type
for k, v in ipairs(mats) do flask:setMaterialCount(k - 1, v) end
