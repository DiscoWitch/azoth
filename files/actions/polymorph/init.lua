dofile_once("mods/azoth/files/lib/disco_util.lua")

table.insert(actions, {
    id = "AZOTH_POLYSELF",
    name = "Polymorph Self",
    description = "Polymorphs you into a creature of your choice",
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
        local shooter = Entity(GetUpdatedEntityID())
        if not shooter or not shooter.Inventory2Component then
            -- Don't do reflection stuff during the metadata scraping
            return
        end
        local wand = Entity(shooter.Inventory2Component.mActiveItem)
        if not wand then
            return
        end
        local cards = GetSpells(wand)
        local me = hand[#hand]
        local mycard = cards[me.deck_index + 1]
        local effect = shooter:addGameEffect("mods/azoth/files/status/target_polymorph/effect.xml")
        effect.GameEffectComponent.polymorph_target = mycard.var_str.entity
        effect.GameEffectComponent.frames = 360
    end
})
