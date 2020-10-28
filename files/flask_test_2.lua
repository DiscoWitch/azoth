function init(entity_id)
    local potion_material = "magic_liquid_protection_all"

    -- load the material from VariableStorageComponent
    local components = EntityGetComponent(entity_id, "VariableStorageComponent")

    if (components ~= nil) then
        for key, comp_id in pairs(components) do
            local var_name = ComponentGetValue(comp_id, "name")
            if (var_name == "potion_material") then
                potion_material = ComponentGetValue(comp_id, "value_string")
            end
        end
    end

    AddMaterialInventoryMaterial(entity_id, potion_material, 1000)
end
