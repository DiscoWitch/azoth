function OnModInit()
    -- dofile_once("mods/azoth/files/materials/inject_material_tags.lua")
    dofile_once("mods/azoth/files/materials/inject_ores.lua")
    dofile_once("mods/azoth/files/materials/inject_electrolysis.lua")
    dofile_once("mods/azoth/files/items/inject_flask.lua")
    dofile_once("mods/azoth/files/items/forge_inject.lua")
end

ModMaterialsFileAdd("mods/azoth/files/materials/materials_append.xml")
ModMaterialsFileAdd("mods/azoth/files/materials/generated/aquaregia.xml")
ModMaterialsFileAdd("mods/azoth/files/actions/necromancy/necromeat.xml")

ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/azoth/files/actions/add_actions.lua")
ModLuaFileAppend("data/scripts/status_effects/status_list.lua", "mods/azoth/files/status/append_status.lua")
ModLuaFileAppend("data/scripts/gun/gun_extra_modifiers.lua", "mods/azoth/files/status/append_modifiers.lua")
ModLuaFileAppend("data/scripts/buildings/forge_item_convert.lua", "mods/azoth/files/items/append_forge_convert.lua")
ModLuaFileAppend("data/scripts/biomes/lavalake.lua", "mods/azoth/files/items/bag_holding/spawn_bag.lua")
