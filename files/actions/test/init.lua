dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
local polytools = dofile_once("mods/azoth/files/lib/polytools/polytools.lua")

table.insert(actions, {
    id = "AZOTH_TEST",
    name = "test",
    description = "testing spell",
    author = "Disco Witch",
    sprite = "data/ui_gfx/gun_actions/light_bullet.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {},
    type = ACTION_TYPE_STATIC_PROJECTILE,
    spawn_level = "96",
    spawn_probability = "0",
    price = 0,
    mana = 0,
    ai_never_uses = true,
    max_uses = -1,
    action = function()
        if reflecting then return end
        local shooter = Entity.Current()
        -- local x, y, angle = shooter:transform()
        -- shooter:setTransform(x, y, angle + math.pi / 4, 1, 1)
        -- do return end
        local controls = shooter.ControlsComponent

        local mpos = controls.mMousePosition

        -- print(tostring(mana))

        -- draw_actions(1, true)

        -- local power = mana
        -- mana = 1

        BeginProjectile("mods/azoth/files/actions/test/projectile.xml")
        BeginTriggerHitWorld()
        local shot = create_shot(1)
        -- apply modifiers to shot.state
        shot.state.testvar = "testvar"
        shot.state.extra_entities = shot.state.extra_entities
                                        .. "mods/azoth/files/actions/test/mod.xml,"
        draw_shot(shot, true)
        EndTrigger()
        EndProjectile()
        -- c.damage_critical_chance = c.damage_critical_chance + power
        -- c.damage_critical_multiplier = c.damage_critical_multiplier + power

        -- if shooter.var_str.spawndata then
        --     polytools.spawn(mpos.x, mpos.y, shooter.var_str.spawndata)
        -- else
        --     local target = Entity.GetInRadius(mpos.x, mpos.y, 10)
        --     if target then
        -- polytools.polymorph(shooter, "data/entities/player.xml", -1, true, nil, true)
        -- local effect = polytools.hide(shooter, -1)
        -- shooter = effect:parent()
        -- shooter:addComponent("InheritTransformComponent")
        -- shooter:setParent(target)

        -- shooter.var_str.spawndata = polytools.save(target)
        -- print(polytools.getPath(target))

        -- end
        -- end
    end
})
