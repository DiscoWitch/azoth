local self = GetUpdatedEntityID();
local my_pc = EntityGetFirstComponent(self, "ProjectileComponent");
local flask = ComponentGetValue2(my_pc, "mWhoShot")

local flask_mic = EntityGetFirstComponentIncludingDisabled(flask, "MaterialInventoryComponent")
local flask_suc = EntityGetFirstComponentIncludingDisabled(flask, "MaterialSuckerComponent")
local flask_mats = ComponentGetValue2(flask_mic, "count_per_material_type")
local fullness = ComponentGetValue2(flask_suc, "mAmountUsed")
local barrel_size = ComponentGetValue2(flask_suc, "barrel_size")
local room_left = barrel_size - fullness
if room_left > 0 then
    local my_mic = EntityGetFirstComponentIncludingDisabled(self, "MaterialInventoryComponent")
    local my_mats = ComponentGetValue2(my_mic, "count_per_material_type")
    for key, value in ipairs(my_mats) do
        if value > 0 and room_left > 0 then
            local matname = CellFactory_GetName(key - 1)
            local fill_amount = math.min(room_left, my_mats[key])
            flask_mats[key] = flask_mats[key] + fill_amount
            my_mats[key] = my_mats[key] - fill_amount
            room_left = room_left - fill_amount
            AddMaterialInventoryMaterial(flask, matname, flask_mats[key])
            AddMaterialInventoryMaterial(self, matname, 0)
            -- I want to make the particles change to the material being vacuumed but it doesn't seem to work
            -- ComponentSetValue2( EntityGetFirstComponent( entity, "ParticleEmitterComponent" ), 
            -- "m_material_id", key )
        end
    end
end

