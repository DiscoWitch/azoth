dofile_once("mods/azoth/files/lib/goki_variables.lua")

table.insert(actions, {
    id = "TURRET",
    name = "Spell turret",
    description = "Conjures a magical turret that casts spells from your wand",
    sprite = "data/ui_gfx/gun_actions/sinewave_unidentified.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_unidentified.png",
    related_projectiles = {"data/entities/projectiles/deck/light_bullet.xml"},
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
        local shooter = GetUpdatedEntityID()
        local i2c = EntityGetFirstComponentIncludingDisabled(shooter, "Inventory2Component")
        local wand = ComponentGetValue2(i2c, "mActiveItem")
        if wand == nil or wand == 0 then
            return
        end
        -- Create a storage entity to pass our spell info to the turret
        local storage = EntityCreateNew("turret_storage")
        local children = {}
        -- Get a list of card items in the order they appear on the wand
        for k, v in ipairs(EntityGetAllChildren(wand)) do
            if EntityHasTag(v, "card_action") then
                table.insert(children, v)
            end
        end
        local store_deck = ""
        local store_iii = ""
        -- Generate ordered lists of cards to populate the turret wand
        for k, v in ipairs(deck) do
            local ind = v.deck_index
            store_deck = store_deck .. tostring(children[ind + 1]) .. ","
            store_iii = store_iii .. tostring(v.inventoryitem_id) .. ","
        end
        -- Store relevant data in the storage entity for the turret to retrieve on spawn
        EntitySetVariableString(storage, "wand", tostring(wand))
        EntitySetVariableString(storage, "deck", store_deck)
        EntitySetVariableString(storage, "inventoryitem_id", store_iii)

        -- Dump the rest of the deck into discard because they're consumed by the turret
        for i, action in ipairs(deck) do
            table.insert(discarded, action)
        end
        deck = {}
    end
})
