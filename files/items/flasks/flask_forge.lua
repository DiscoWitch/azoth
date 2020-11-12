dofile_once("mods/azoth/files/lib/disco_util.lua")

function MoveMaterials(from, to)
    local mats = from.MaterialInventoryComponent.count_per_material_type
    for k, v in ipairs(mats) do
        local matname = CellFactory_GetName(k - 1)
        AddMaterialInventoryMaterial(to:id(), matname, v)
    end
end

function HasMaterial(item, mat_name, amount)
    local mats = item.MaterialInventoryComponent.count_per_material_type
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

function CanConvert(fdata)
    return true
end

function Convert(fdata)
    local item = fdata:parent()
    local x, y = item:transform()
    -- If the flask is full of teleportatium, make a vacuum flask
    if HasMaterial(item,
        {"magic_liquid_teleportation", "magic_liquid_unstable_teleportation", "magic_liquid_elsewhere"}, 500) then
        EntityLoad("mods/azoth/files/items/flasks/flask_vacuum.xml", x, y)
    elseif HasMaterial(item, {"magic_liquid_chaos"}, 500) then
        -- Create a bag of holding
        EntityLoad("mods/azoth/files/items/bag_holding/bag.xml", x, y)
    else
        -- Otherwise, just reinforce the flask
        local new_flask = Entity(EntityLoad("mods/azoth/files/items/flasks/flask_metal.xml", x, y))
        MoveMaterials(item, new_flask)
    end
    item:kill()
    converted = true
end

return {
    can_convert = CanConvert,
    convert = Convert
}
