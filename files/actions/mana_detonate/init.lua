dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

table.insert(actions, {
    id = "AZOTH_MANA_DETONATE",
    name = "Manaclysm",
    description = "Detonates all of the mana in your wand.",
    author = "Disco Witch",
    sprite = "mods/azoth/files/actions/mana_detonate/icon.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {},
    type = ACTION_TYPE_STATIC_PROJECTILE,
    spawn_level = "0,1,2,3,4,5",
    spawn_probability = "0.1,0.1,0.1,0.1,0.1,0.1",
    price = 100,
    mana = 0,
    max_uses = -1,
    action = function()
        if reflecting then return end
        mana_stack = mana_stack or {}
        local power = math.floor((mana - 1) / (#mana_stack + 1))

        add_projectile("mods/azoth/files/actions/mana_detonate/explosion.xml")
        c.action_mana_drain = power

        c.fire_rate_wait = c.fire_rate_wait + 30
        mana = mana - power
    end
})
