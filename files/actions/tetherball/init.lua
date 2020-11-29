dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

table.insert(actions, {
    id = "AZOTH_TETHERBALL",
    name = "Tetherball",
    description = "Causes your spells to tether nearby objects",
    sprite = "mods/azoth/files/actions/tetherball/icon.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/explosive_projectile_unidentified.png",
    type = ACTION_TYPE_MODIFIER,
    spawn_level = "2,3,4,5",
    spawn_probability = "0.6,0.6,0.6,0.6",
    price = 100,
    mana = 50,
    ai_never_uses = true,
    max_uses = -1,
    action = function()
        c.extra_entities = c.extra_entities .. "mods/azoth/files/actions/tetherball/mod.xml,"
        c.fire_rate_wait = c.fire_rate_wait + 10
        draw_actions(1, true)
    end
})

