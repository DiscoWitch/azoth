dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

table.insert(actions, {
    id = "AZOTH_LARPA",
    name = "Eternal Larpa",
    description = "Causes a spell to cast a perfect copy of itself on death",
    author = "Disco Witch",
    sprite = "mods/azoth/files/actions/larpa/icon.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {},
    type = ACTION_TYPE_MODIFIER,
    spawn_level = "10",
    spawn_probability = "0.1",
    price = 300,
    mana = 150,
    ai_never_uses = true,
    max_uses = -1,
    action = function()
        if reflecting then return end
        c.fire_rate_wait = c.fire_rate_wait + 60
        BeginProjectile("mods/azoth/files/actions/larpa/host.xml")
        BeginTriggerHitWorld()
        local shot = create_shot(1)
        shot.state.extra_entities = shot.state.extra_entities
                                        .. "mods/azoth/files/actions/larpa/mod.xml,"
        draw_shot(shot, true)
        EndTrigger()
        EndProjectile()
    end
})
