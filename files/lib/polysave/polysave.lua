dofile_once("mods/azoth/files/lib/disco_util.lua")

function polypath(entity, data_ent, data_name, depoly_script)
    if not entity or not entity:alive() then
        print_error("Attempted to polysave an entity that doesn't exist")
        return
    end
    -- Special handling here to prevent unintended effects
    if entity.ProjectileComponent then
        entity.ProjectileComponent.on_death_explode = false
    end
    if entity.ProjectileComponent or entity.PhysicsBodyComponent then
        entity:addComponent("LuaComponent", {
            execute_every_n_frame = 1,
            remove_after_executed = true,
            script_source_file = "mods/azoth/files/lib/polysave/polyfix.lua"
        })
    end
    -- For if the use case needs adjustments made for each loaded entity
    if depoly_script then
        entity:addComponent("LuaComponent", {
            execute_every_n_frame = 1,
            remove_after_executed = true,
            script_source_file = depoly_script
        })
    end

    local effect = entity:addGameEffect("mods/azoth/files/lib/polysave/effect.xml")
    effect.var_bool.save_path = true
    effect.var_int.save_path = data_ent
    effect.var_str.save_path = data_name
    return effect
end

function polysave(entity, data_ent, data_name, depoly_script)
    if not entity or not entity:alive() then
        print_error("Attempted to polysave an entity that doesn't exist")
        return
    end
    if entity.PhysicsBody2Component then
        print_error("Cannot clone entities with PhysicsBody2Components")
        return
    end
    -- Special handling here to prevent unintended effects
    if entity.ProjectileComponent then
        entity.ProjectileComponent.on_death_explode = false
    end
    if entity.ProjectileComponent or entity.PhysicsBodyComponent then
        entity:addComponent("LuaComponent", {
            execute_every_n_frame = 1,
            remove_after_executed = true,
            script_source_file = "mods/azoth/files/lib/polysave/polyfix.lua"
        })
    end
    -- For if the use case needs adjustments made for each loaded entity
    if depoly_script then
        entity:addComponent("LuaComponent", {
            execute_every_n_frame = 1,
            remove_after_executed = true,
            script_source_file = depoly_script
        })
    end

    local effect = entity:addGameEffect("mods/azoth/files/lib/polysave/effect.xml")
    effect.var_bool.save_data = true
    effect.var_int.save_data = data_ent
    effect.var_str.save_data = data_name
    return effect
end

function polyload(entity, data)
    -- Special handling here to prevent unintended effects
    local effect = entity:addGameEffect("mods/azoth/files/lib/polysave/effect.xml")
    effect.var_bool.load_data = true
    effect.var_str.load_data = data
    return effect
end

function polyspawn(x, y, data)
    local entity = Entity(EntityCreateNew())
    entity:setTransform(x, y)
    return polyload(entity, data)
end
