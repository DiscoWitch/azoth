dofile_once("mods/azoth/files/lib/disco_util.lua")

for i = 1, #actions do
    if actions[i].id == "NECROMANCY" then
        actions[i].action = function()
            c.extra_entities = c.extra_entities .. "mods/azoth/files/actions/necromancy/mod.xml,"
            c.fire_rate_wait = c.fire_rate_wait + 10
            draw_actions(1, true)
        end
        break
    end
end

-- table.insert(actions, {
--     id = "AZOTH_NECROMANCY",
--     name = "Greater Necromancy",
--     description = "Causes a spell to cast a perfect copy of itself on death",
--     sprite = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
--     sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
--     related_projectiles = {},
--     type = ACTION_TYPE_MODIFIER,
--     spawn_level = "96",
--     spawn_probability = "0",
--     price = 0,
--     mana = 0,
--     ai_never_uses = true,
--     max_uses = -1,
--     action = 
-- })
