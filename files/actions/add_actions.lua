local azoth_spells = {
    "blink_cast",
    "sight",
    "tether",
    "leash",
    "turret",
    "writable",
    "larpa",
    "larpa_field",
    "necromancy",
    "polymorph",
    "mana_detonate"
    -- "mana_empower"
}
for _, v in ipairs(azoth_spells) do dofile_once("mods/azoth/files/actions/" .. v .. "/init.lua") end

-- Only add the test spell when debugging
if DebugGetIsDevBuild and DebugGetIsDevBuild() then
    dofile_once("mods/azoth/files/actions/test/init.lua")
end
