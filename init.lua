-- This code runs when all mods' filesystems are registered
-- ModMagicNumbersFileAdd( "mods/azoth/files/magic_numbers.xml" ) -- Will override some magic numbers using the specified file
-- ModRegisterAudioEventMappings( "mods/azoth/files/audio_events.txt" ) -- Use this to register custom fmod events. Event mapping files can be generated via File -> Export GUIDs in FMOD Studio.
ModMaterialsFileAdd("mods/azoth/files/materials_append.xml")
ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/azoth/files/actions/tether/init.lua");
ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/azoth/files/actions/leash/init.lua");
ModLuaFileAppend("data/scripts/status_effects/status_list.lua", "mods/azoth/files/status_append.lua");
ModLuaFileAppend("data/scripts/electrolysis.lua", "mods/azoth/files/materials/electrolysis.lua");

print("azoth mod init done")
