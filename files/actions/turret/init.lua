dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

table.insert(actions, {
    id = "AZOTH_TURRET",
    name = "Spell turret",
    description = "Conjures a magical turret that casts spells from your wand",
    author = "Disco Witch",
    sprite = "mods/azoth/files/actions/turret/icon.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {"mods/azoth/files/actions/turret/turret.xml"},
    type = ACTION_TYPE_STATIC_PROJECTILE,
    spawn_level = "0,1,2,3,4,5,6,10",
    spawn_probability = "0,0,0,0.1,0.1,0.1,0.2,0.3",
    price = 500,
    mana = 300,
    ai_never_uses = true,
    max_uses = -1,
    action = function()
        add_projectile("mods/azoth/files/actions/turret/turret.xml")
        c.fire_rate_wait = c.fire_rate_wait + 60
        -- Returns the entity shooting the wand
        local shooter = Entity.Current()
        if not shooter or not shooter.Inventory2Component then
            -- Don't do reflection stuff during the metadata scraping
            return
        end
        local wand = Entity(shooter.Inventory2Component.mActiveItem)
        if not wand then return end

        -- Create a storage entity to pass our spell info to the turret
        local storage = Entity(EntityCreateNew("turret_storage"))
        local cards = GetSpells(wand)

        local store_deck = ""
        -- The iii is used to synchronize spell uses
        local store_iii = ""
        -- Generate ordered lists of cards to populate the turret wand
        for k, v in ipairs(deck) do
            store_deck = store_deck .. tostring(cards[v.deck_index + 1]:id()) .. ","
            store_iii = store_iii .. tostring(v.inventoryitem_id) .. ","
        end
        -- Store relevant data in the storage entity for the turret to retrieve on spawn
        storage.variables.wand = tostring(wand:id())
        storage.variables.deck = store_deck
        storage.variables.inventoryitem_id = store_iii

        -- Dump the rest of the deck into discard because they're consumed by the turret
        for i, action in ipairs(deck) do table.insert(discarded, action) end
        deck = {}
    end
})
table.insert(actions, {
    id = "AZOTH_TURRET_PATIENT",
    name = "Calculating Spell Turret",
    description = "Conjures a magical turret that casts spells from your wand, but only when enemies are in range",
    author = "Disco Witch",
    sprite = "mods/azoth/files/actions/turret/icon2.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {"mods/azoth/files/actions/turret_patient/turret.xml"},
    type = ACTION_TYPE_STATIC_PROJECTILE,
    spawn_level = "0,1,2,3,4,5,6,10",
    spawn_probability = "0,0,0,0.1,0.1,0.1,0.2,0.3",
    price = 500,
    mana = 300,
    ai_never_uses = true,
    max_uses = -1,
    action = function()
        add_projectile("mods/azoth/files/actions/turret/turret_patient.xml")
        c.fire_rate_wait = c.fire_rate_wait + 60
        -- Returns the entity shooting the wand
        local shooter = Entity.Current()
        if not shooter or not shooter.Inventory2Component then
            -- Don't do reflection stuff during the metadata scraping
            return
        end
        local wand = Entity(shooter.Inventory2Component.mActiveItem)
        if wand == nil then return end

        -- Create a storage entity to pass our spell info to the turret
        local storage = Entity(EntityCreateNew("turret_storage"))
        local cards = GetSpells(wand)

        local store_deck = ""
        -- The iii is used to synchronize spell uses
        local store_iii = ""
        -- Generate ordered lists of cards to populate the turret wand
        for k, v in ipairs(deck) do
            store_deck = store_deck .. tostring(cards[v.deck_index + 1]:id()) .. ","
            store_iii = store_iii .. tostring(v.inventoryitem_id) .. ","
        end
        -- Store relevant data in the storage entity for the turret to retrieve on spawn
        storage.variables.wand = tostring(wand:id())
        storage.variables.deck = store_deck
        storage.variables.inventoryitem_id = store_iii

        -- Dump the rest of the deck into discard because they're consumed by the turret
        for i, action in ipairs(deck) do table.insert(discarded, action) end
        deck = {}
    end
})
