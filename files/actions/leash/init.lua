table.insert(actions, {
    id = "LEASH",
    name = "leash",
    description = "leashes objects to yourself",
    sprite = "data/ui_gfx/gun_actions/light_bullet.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {"data/entities/projectiles/deck/light_bullet.xml"},
    type = ACTION_TYPE_PROJECTILE,
    spawn_level = "0,1,2,3,4,5,6",
    spawn_probability = "1,1,1,1,1,1,1",
    price = 0,
    mana = 10,
    max_uses = -1,
    action = function()
        add_projectile("mods/azoth/files/actions/leash/projectile.xml");
    end
})
