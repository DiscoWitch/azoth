dofile_once("mods/azoth/files/lib/disco_util.lua")
local self = Entity.Current()
local start_size = tonumber(ModSettingGet("azoth.bag_holding.size"))
self.AbilityComponent.gun_config.deck_capacity = start_size

if ModSettingGet("azoth.bag_holding.ewe") then
    self:addComponent("LuaComponent", {
        _tags = "enabled_in_hand",
        execute_every_n_frame = 12,
        script_source_file = "mods/azoth/files/items/bag_holding/bag_ewe.lua"
    })
end

if ModSettingGet("azoth.bag_holding.bottomless") then
    self:addComponent("LuaComponent", {
        _tags = "enabled_in_hand",
        execute_every_n_frame = 1,
        script_source_file = "mods/azoth/files/items/bag_holding/bag_cycle.lua"
    })
end
