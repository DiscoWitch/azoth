table.insert(actions, {
    id = "LEASH",
    name = "leash",
    description = "leashes objects to yourself",
    sprite = "data/ui_gfx/gun_actions/light_bullet.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {"data/entities/projectiles/deck/light_bullet.xml"},
    type = ACTION_TYPE_PROJECTILE,
    spawn_level = "0,1,2,3,4,5,6,10",
    spawn_probability = "0,0,0,0.1,0.1,0.1,0.2,0.3",
    price = 300,
    mana = 50,
    max_uses = -1,
    ai_never_uses = true,
    action = function()
        add_projectile("mods/azoth/files/actions/leash/projectile.xml");
        c.fire_rate_wait = c.fire_rate_wait + 15
    end
})
