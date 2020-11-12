function AddComponent(entity_file, component)
    local ent = ModTextFileGetContent(entity_file)
    ent = string.gsub(ent, "(</Entity>%s*)$", component .. "\n%1\n")
    ModTextFileSetContent(entity_file, ent)
end

local potions = {"data/entities/items/pickup/potion.xml", "data/entities/items/pickup/potion_water.xml",
                 "data/entities/items/pickup/potion_alcohol.xml", "data/entities/items/pickup/potion_aggressive.xml"}

local component = [[<LuaComponent _tags="enabled_in_world,enabled_in_hand,enabled_in_inventory"
                execute_on_added="1"
                remove_after_executed="1"
                script_source_file="mods/azoth/files/items/flasks/flask_add_components.lua" />]]
for k, v in ipairs(potions) do
    AddComponent(v, component)
end
