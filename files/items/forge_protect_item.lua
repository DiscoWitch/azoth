dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity.Current()
local x, y = self:transform()
local drag = 1000
local pull = 1

for _, fdata in ipairs(EntityGetInRadiusWithTag(x, y, 70, "forgeable")) do
    fdata = Entity(fdata)
    local item = fdata:parent()
    -- make sure item is not carried in inventory or wand
    if fdata:name() == "azoth_forge_data" and fdata:root():id() == item:id() then
        local ix, iy = item:transform()
        local prev_x = fdata.var_float.prev_x or ix
        local prev_y = fdata.var_float.prev_y or iy
        local vx = (ix - prev_x) / 60
        local vy = (iy - prev_y) / 60

        local fx = -drag * vx + pull * (x - ix)
        local fy = -drag * vy + pull * (y - iy)

        item:applyForce(fx, fy)

        fdata.var_float.prev_x = ix
        fdata.var_float.prev_y = iy
    end
end
