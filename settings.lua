dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.

function mod_setting_bool_custom(mod_id, gui, in_main_menu, im_id, setting)
    local value = ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))
    local text = setting.ui_name .. " - " .. GameTextGet(value and "$option_on" or "$option_off")

    if GuiButton(gui, im_id, mod_setting_group_x_offset, 0, text) then
        ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), not value, false)
    end

    mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
end

function mod_setting_change_callback(mod_id, gui, in_main_menu, setting, old_value, new_value)
    print(tostring(new_value))
end

local mod_id = "azoth" -- This should match the name of your mod's folder.
mod_settings_version = 0.1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value. 
mod_settings = {
    {
        id = "necromancy_replace",
        ui_name = "Replace Necromancy",
        ui_description = "The Azoth necromancy spell replace vanilla necromancy instead of spawning separately.",
        value_default = false,
        scope = MOD_SETTING_SCOPE_NEW_GAME
    },
    {
        category_id = "bag_holding",
        ui_name = "Bag of Holding",
        ui_description = "Settings for the bag of holding",
        settings = {
            {
                id = "bag_holding.size",
                ui_name = "Starting Size",
                ui_description = "Sets the starting size of the bag of holding",
                value_default = "5",
                values = {{"5", "5"}, {"10", "10"}, {"15", "15"}},
                scope = MOD_SETTING_SCOPE_NEW_GAME
            },
            {
                id = "bag_holding.ewe",
                ui_name = "Start with Edit Wands Everywhere passive",
                ui_description = "Adds the Edit Wands Everywhere passive to the bag at the start instead of as an upgrade.",
                value_default = false,
                scope = MOD_SETTING_SCOPE_NEW_GAME
            },
            {
                id = "bag_holding.bottomless",
                ui_name = "Start with Bottomless upgrade",
                ui_description = "Makes the bag bottomless at the start instead of as an upgrade.",
                value_default = false,
                scope = MOD_SETTING_SCOPE_NEW_GAME
            }
        }
    }
}

function ModSettingsUpdate(init_scope)
    local old_version = mod_settings_get_version(mod_id) -- This can be used to migrate some settings between mod versions.
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount() return mod_settings_gui_count(mod_id, mod_settings) end

function ModSettingsGui(gui, in_main_menu) mod_settings_gui(mod_id, mod_settings, gui, in_main_menu) end
