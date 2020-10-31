function OnModInit()
    dofile_once("mods/azoth/files/materials/inject_ores.lua")
    dofile_once("mods/azoth/files/materials/add_electrolysis.lua")
    dofile_once("mods/azoth/files/items/palestone/flask_inject.lua")
end

ModMaterialsFileAdd("mods/azoth/files/materials/materials_append.xml")
ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/azoth/files/actions/add_actions.lua")
ModLuaFileAppend("data/scripts/status_effects/status_list.lua", "mods/azoth/files/status_append.lua")

