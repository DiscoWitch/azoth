dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local black_hole = self:parent()
if not black_hole or not black_hole:alive() then return end

local px, py = black_hole:transform()
local angle = math.random() * 2 * math.pi
local radius = black_hole.BlackHoleComponent.radius or 1
self:setTransform(px + radius * math.cos(angle), py + radius * math.sin(angle))

local flask_mats = black_hole.MaterialInventoryComponent.count_per_material_type
local my_mats = self.MaterialInventoryComponent.count_per_material_type

local had_mat = false
-- Put as much of the vacuum's contents into the flask as will fit
for key, value in ipairs(my_mats) do
    if value > 0 then
        flask_mats[key] = flask_mats[key] + my_mats[key]
        black_hole:setMaterialCount(key - 1, flask_mats[key])
        had_mat = true
    end
end

local x, y = self:transform()

for key, value in ipairs(my_mats) do if value > 0 then self:setMaterialCount(key - 1, 0) end end
