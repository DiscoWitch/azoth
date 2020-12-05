table.insert(actions, {
    id = "AZOTH_BLINK",
    name = "Blink Cast",
    description = "Casts a spell at the mouse cursor",
    author = "Disco Witch",
    sprite = "mods/azoth/files/actions/blink_cast/icon.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {"mods/azoth/files/actions/blink_cast/projectile.xml"},
    type = ACTION_TYPE_UTILITY,
    spawn_level = "0,1,2,4,5,6", -- TELEPORT_CAST
    spawn_probability = "0.6,0.6,0.6,0.6,0.6,0.6", -- TELEPORT_CAST
    price = 190,
    mana = 100,
    max_uses = -1,
    action = function()
        add_projectile_trigger_death("mods/azoth/files/actions/blink_cast/projectile.xml", 1)
        c.spread_degrees = c.spread_degrees + 360
    end
})
