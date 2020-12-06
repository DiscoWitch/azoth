dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
local polytools = dofile_once("mods/azoth/files/lib/polytools/polytools.lua")

table.insert(actions, {
    id = "AZOTH_POLYSELF",
    name = "Polymorph Self",
    description = "Polymorphs you into a creature of your choice",
    author = "Disco Witch",
    sprite = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {},
    type = ACTION_TYPE_OTHER,
    spawn_level = "96",
    spawn_probability = "0",
    price = 0,
    mana = 0,
    max_uses = -1,
    custom_xml_file = "mods/azoth/files/actions/polymorph/card.xml",
    action = function()
        if reflecting then return end
        local shooter = Entity.Current()
        local wand = Entity(shooter.Inventory2Component.mActiveItem)
        if not wand then return end
        local cards = GetSpells(wand)
        local me = hand[#hand]
        local mycard = cards[me.deck_index + 1]
        polytools.polymorph(shooter, mycard.var_str.entity, 1800, true, "", true)
    end
})
