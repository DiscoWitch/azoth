dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
dofile_once("mods/azoth/files/lib/polytools/polytools_init.lua").init(
    "mods/azoth/files/lib/polytools/")

function OnModInit()
    -- dofile_once("mods/azoth/files/materials/inject_material_tags.lua")
    dofile_once("mods/azoth/files/materials/inject_ores.lua")
    dofile_once("mods/azoth/files/materials/inject_electrolysis.lua")
    -- dofile_once("mods/azoth/files/items/inject_flask.lua")
    dofile_once("mods/azoth/files/items/forge_inject.lua")
end

function OnPlayerSpawned(player_entity) -- This runs when player entity has been created
    local player = Entity(player_entity)
    -- Only do this init once per player
    if player.var_bool.azoth_init then return end
    player:addComponent("LuaComponent", {
        script_source_file = "mods/azoth/files/items/held_item_components.lua",
        execute_every_n_frame = 120
    })
    local start_items = {
        bag_holding = "mods/azoth/files/items/containers/bag_holding/bag.xml",
        magician_deck = "mods/azoth/files/items/containers/magician_deck/deck.xml",
        lodestone = "mods/azoth/files/items/lodestone/lodestone.xml",
        palestone = "mods/azoth/files/items/palestone/palestone.xml",
        flask_vacuum = "mods/azoth/files/items/flasks/flask_vacuum/flask.xml",
        flask_black_hole = "mods/azoth/files/items/flasks/flask_black_hole/flask.xml"
    }
    local x, y = EntityGetTransform(player_entity)
    for k, v in pairs(start_items) do
        x = x - 10
        if ModSettingGet("azoth.start_items." .. k) then EntityLoad(v, x, y - 20) end
    end
    player.var_bool.azoth_init = true
end

ModMaterialsFileAdd("mods/azoth/files/materials/materials_append.xml")
ModMaterialsFileAdd("mods/azoth/files/materials/generated/aquaregia.xml")
ModMaterialsFileAdd("mods/azoth/files/actions/necromancy/necromeat.xml")

ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/azoth/files/actions/add_actions.lua")
ModLuaFileAppend("data/scripts/status_effects/status_list.lua",
                 "mods/azoth/files/status/append_status.lua")
ModLuaFileAppend("data/scripts/gun/gun_extra_modifiers.lua",
                 "mods/azoth/files/status/append_modifiers.lua")
ModLuaFileAppend("data/scripts/buildings/forge_item_convert.lua",
                 "mods/azoth/files/items/append_forge_convert.lua")
ModLuaFileAppend("data/scripts/biomes/lavalake.lua",
                 "mods/azoth/files/items/containers/bag_holding/spawn_bag.lua")
