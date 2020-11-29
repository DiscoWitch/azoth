dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local flask = Entity(self.ProjectileComponent.mWhoShot)
if not flask then return end

local flask_mats = flask.MaterialInventoryComponent.count_per_material_type
local flask_suc = flask.MaterialSuckerComponent
local room_left = flask_suc.barrel_size - flask_suc.mAmountUsed
local my_mats = self.MaterialInventoryComponent.count_per_material_type

local had_mat = false
if room_left > 0 then
    -- Put as much of the vacuum's contents into the flask as will fit
    for key, value in ipairs(my_mats) do
        if value > 0 and room_left > 0 then
            local fill_amount = math.min(room_left, my_mats[key])
            flask_mats[key] = flask_mats[key] + fill_amount
            my_mats[key] = my_mats[key] - fill_amount
            room_left = room_left - fill_amount
            flask:setMaterialCount(key - 1, flask_mats[key])
            had_mat = true
        end
    end
end

local x, y = self:transform()
if had_mat then
    -- Generate particles that look like the material going into the flask
    local particle = Entity(EntityLoad("mods/azoth/files/items/flasks/flask_vacuum/particle.xml", x,
                                       y))
    particle:setParent(flask)
    local fx, fy = flask:transform()
    local p = particle.ParticleEmitterComponent
    p.m_next_emit_frame = GameGetFrameNum() + 1
    p.offset = {x = x - fx, y = y - fy}
    p.color = GameGetPotionColorUint(self:id())
end

-- On death, spray any materials that can't be sent to the flask
for key, value in ipairs(my_mats) do
    if value > 0 then
        local matname = CellFactory_GetName(key - 1)
        GameCreateParticle(matname, x, y, value, 0, 0, false)
    end
end
