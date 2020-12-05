table.insert(actions, {
    id = "AZOTH_LEASH",
    name = "Leash",
    description = "leashes objects to yourself",
    author = "Disco Witch",
    sprite = "mods/azoth/files/actions/leash/icon.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {"mods/azoth/files/actions/leash/projectile.xml"},
    type = ACTION_TYPE_PROJECTILE,
    spawn_level = "0,1,2,3,4,5,6,10",
    spawn_probability = "0,0,0,0.1,0.1,0.1,0.2,0.3",
    price = 300,
    mana = 50,
    max_uses = -1,
    action = function()
        add_projectile("mods/azoth/files/actions/leash/projectile.xml");
        c.fire_rate_wait = c.fire_rate_wait + 15
    end
})
