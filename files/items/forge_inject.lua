function AddComponent(entity_file, component)
    local ent = ModTextFileGetContent(entity_file)
    ent = string.gsub(ent, "(</Entity>%s*)$", component .. "\n%1\n")
    ModTextFileSetContent(entity_file, ent)
end

local component = [[
<CollisionTriggerComponent
    width="40"
    height="40"
    radius="40"
    destroy_this_entity_when_triggered="0"
    required_tag="forgeable" />
<LuaComponent 
    execute_every_n_frame="-1"
    script_collision_trigger_hit="mods/azoth/files/items/forge_check.lua" />
]]
AddComponent("data/entities/buildings/forge_item_check.xml", component)

component = [[
    <LuaComponent 
    execute_every_n_frame="1"
    script_source_file="mods/azoth/files/items/forge_protect_item.lua" />
]]
AddComponent("data/entities/buildings/forge_item_convert.xml", component)

