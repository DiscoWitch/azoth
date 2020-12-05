dofile_once("mods/azoth/files/actions/blink_cast/init.lua")
dofile_once("mods/azoth/files/actions/sight/init.lua")
dofile_once("mods/azoth/files/actions/tether/init.lua")
dofile_once("mods/azoth/files/actions/leash/init.lua")
dofile_once("mods/azoth/files/actions/turret/init.lua")
dofile_once("mods/azoth/files/actions/writable/init.lua")
dofile_once("mods/azoth/files/actions/larpa/init.lua")
dofile_once("mods/azoth/files/actions/larpa_field/init.lua")
dofile_once("mods/azoth/files/actions/necromancy/init.lua")
dofile_once("mods/azoth/files/actions/polymorph/init.lua")

-- Only add the test spell when debugging
if DebugGetIsDevBuild and DebugGetIsDevBuild() then
    dofile_once("mods/azoth/files/actions/test/init.lua")
end
