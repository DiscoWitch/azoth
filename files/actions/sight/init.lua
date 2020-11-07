dofile_once("mods/azoth/files/lib/disco_util.lua")

table.insert(actions, {
    id = "AZOTH_SIGHT",
    name = "laser sight",
    description = "Projects a laser sight from the tip of your wand",
    sprite = "mods/azoth/files/actions/sight/icon.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {},
    type = ACTION_TYPE_PASSIVE,
    spawn_level = "0,1,2,3,4,5,6,10",
    spawn_probability = "0.5,0.4,0.3,0.2,0.1,0,0,0",
    price = 50,
    mana = 0,
    max_uses = -1,
    custom_xml_file = "mods/azoth/files/actions/sight/card.xml",
    action = function()

    end
})
