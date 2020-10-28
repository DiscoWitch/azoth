potions_list = {{
    weight = 69,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/potion.xml", x, y - 2)
    end
}, {
    weight = 1,
    condition = function()
        return HasFlagPersistent("card_unlocked_duplicate")
    end,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/physics_die.xml", x, y - 12)
    end
}, {
    weight = 1,
    func = function(x, y)
        local opts = {"laser", "fireball", "lava", "slow", "null", "disc"}
        local rnd = Random(1, #opts)
        local opt = opts[rnd]

        local entity_id = EntityLoad("data/entities/items/pickup/runestones/runestone_" .. opt .. ".xml", x, y - 10)

        rnd = Random(1, 10)

        if (rnd == 2) then
            runestone_activate(entity_id)
        end
    end
}, {
    weight = 1,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/egg_purple.xml", x, y - 2)
    end
}, {
    weight = 2,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/egg_fire.xml", x, y - 2)
    end
}, {
    weight = 4,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/egg_slime.xml", x, y - 2)
    end
}, {
    weight = 2,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/egg_monster.xml", x, y - 2)
    end
}, {
    weight = 4,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/brimstone.xml", x, y - 2)
    end
}, {
    weight = 2,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/thunderstone.xml", x, y - 2)
    end
}, {
    weight = 4,
    func = function(x, y)
        EntityLoad("data/entities/items/pickup/broken_wand.xml", x, y - 2)
    end
}}
