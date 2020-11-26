dofile_once("mods/azoth/files/lib/disco_util.lua")

table.insert(actions,
             {id = "AZOTH_WRITABLE", name = "Variable Spell", description = "Variable Spell",
              sprite = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
              sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
              related_projectiles = {}, type = ACTION_TYPE_PROJECTILE, spawn_level = "96",
              spawn_probability = "0", price = 0, mana = 0, max_uses = -1,
              custom_xml_file = "mods/azoth/files/actions/writable/card.xml", action = function()
    local shooter = Entity.Current()
    if not shooter or not shooter.Inventory2Component then
        -- Don't do reflection stuff during the metadata scraping
        return
    end
    local wand = Entity(shooter.Inventory2Component.mActiveItem)
    if not wand then return end
    local cards = GetSpells(wand)
    local me = hand[#hand]
    local mycard = cards[me.deck_index + 1]
    c.fire_rate_wait = mycard.var_int.fire_rate_wait or 1
    local multishot_min = mycard.var_int.multishot_min or 1
    local multishot_max = mycard.var_int.multishot_max or multishot_min
    if mycard.var_str.projectile then
        for i = 1, math.random(multishot_min, multishot_max) do
            add_projectile(mycard.var_str.projectile)
        end
    end

    -- Dump the rest of the deck into discard so we can rotate spells
    for i, action in ipairs(deck) do table.insert(discarded, action) end
    deck = {}
end})
