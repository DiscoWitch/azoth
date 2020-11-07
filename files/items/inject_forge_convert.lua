function is_potion(id)
    local ic = EntityGetFirstComponentIncludingDisabled(id, "ItemComponent")
    return ComponentGetValue2(ic, "item_name") == "$item_potion"
end

function move_materials(from, to)
    local mic_from = EntityGetFirstComponentIncludingDisabled(from, "MaterialInventoryComponent")
    local mats = ComponentGetValue2(mic_from, "count_per_material_type")
    for k, v in ipairs(mats) do
        local matname = CellFactory_GetName(k - 1)
        AddMaterialInventoryMaterial(to, matname, v)
    end
end

function has_material(id, mat_name, amount)
    local mic = EntityGetFirstComponentIncludingDisabled(id, "MaterialInventoryComponent")
    local mats = ComponentGetValue2(mic, "count_per_material_type")
    if type(mat_name) == "string" then
        return mats[CellFactory_GetType(mat_name) + 1] > amount
    else
        local count = 0
        for k, v in ipairs(mat_name) do
            count = count + mats[CellFactory_GetType(v) + 1]
        end
        return count > amount
    end
end

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)

converted = false
for _, id in pairs(EntityGetInRadiusWithTag(pos_x, pos_y, 70, "item_physics")) do
    -- make sure item is not carried in inventory or wand
    if EntityGetRootEntity(id) == id then
        if is_potion(id) then
            local x, y = EntityGetTransform(id)
            -- If the flask is full of teleportatium, make a vacuum flask
            if has_material(id, {"magic_liquid_teleportation", "magic_liquid_unstable_teleportation",
                                 "magic_liquid_elsewhere"}, 500) then

                EntityLoad("mods/azoth/files/items/flasks/flask_vacuum.xml", x, y)
            elseif has_material(id, {"magic_liquid_chaos"}, 500) then
                EntityLoad("mods/azoth/files/items/bag_holding/bag.xml", x, y)
            else
                -- Otherwise, just reinforce the flask
                local new_flask = EntityLoad("mods/azoth/files/items/flasks/flask_metal.xml", x, y)
                move_materials(id, new_flask)
            end
            EntityKill(id)
            converted = true
        end
    end
end
if converted then
    GameTriggerMusicFadeOutAndDequeueAll(3.0)
    GameTriggerMusicEvent("music/oneshot/dark_01", true, pos_x, pos_y)
end
