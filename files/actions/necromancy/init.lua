dofile_once("mods/azoth/files/lib/disco_util.lua")

if ModSettingGet("azoth.necromancy_replace") then
    for i = 1, #actions do
        if actions[i].id == "NECROMANCY" then
            actions[i].action = function()
                c.extra_entities =
                    c.extra_entities .. "mods/azoth/files/actions/necromancy/mod.xml,"
                c.fire_rate_wait = c.fire_rate_wait + 10
                draw_actions(1, true)
            end
            break
        end
    end
else
    table.insert(actions, {
        id = "AZOTH_NECROMANCY",
        name = "Greater Necromancy",
        description = "Causes killed enemies to reanimate and fight for you",
        spawn_requires_flag = "card_unlocked_necromancy",
        sprite = "mods/azoth/files/actions/necromancy/icon.png",
        sprite_unidentified = "data/ui_gfx/gun_actions/explosive_projectile_unidentified.png",
        type = ACTION_TYPE_MODIFIER,
        spawn_level = "2,3,4,5", -- NECROMANCY
        spawn_probability = "0.6,0.6,0.6,0.6", -- NECROMANCY
        price = 100,
        mana = 50,
        ai_never_uses = true,
        max_uses = -1,
        action = function()
            c.extra_entities = c.extra_entities .. "mods/azoth/files/actions/necromancy/mod.xml,"
            c.fire_rate_wait = c.fire_rate_wait + 10
            draw_actions(1, true)
        end
    })
end

