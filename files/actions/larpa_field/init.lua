table.insert(actions, {
    id = "AZOTH_LARPA_FIELD",
    name = "Larpa Lens",
    description = "Creates a field that duplicates projectiles passing through it",
    sprite = "mods/azoth/files/actions/larpa_field/icon.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {"mods/azoth/files/actions/larpa_field/field.xml"},
    type = ACTION_TYPE_STATIC_PROJECTILE,
    spawn_level = "0,1,2,3,4,5,6,10",
    spawn_probability = "0,0,0,0.1,0.1,0.1,0.2,0.3",
    price = 300,
    mana = 50,
    max_uses = -1,
    action = function()
        add_projectile("mods/azoth/files/actions/larpa_field/field.xml");
        c.fire_rate_wait = c.fire_rate_wait + 15
    end
})
