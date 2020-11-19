dofile_once("mods/azoth/files/lib/disco_util.lua")
local basepath = "mods/azoth/files/lib/polytools/"
local base64 = dofile_once(basepath .. "base64.lua")

local polytools = {}
function polytools.polymorph(target, poly_into, duration, keep_ui, components_file, end_on_death)
    if type(target) == "number" then
        target = Entity(target)
    end
    if not target or not target:alive() then
        print_error("Attempted to polysave an entity that doesn't exist")
        return
    end
    local proj = target.ProjectileComponent
    if proj and proj.on_death_explode then
        proj.on_death_explode = false
        target:addComponent("LuaComponent", {
            script_source_file = basepath .. "fix_projectiles.lua",
            execute_every_n_frame = 0,
            remove_after_executed = true
        })
    end
    local effect = target:addGameEffect(basepath .. "effect.xml")
    effect.GameEffectComponent.polymorph_target = poly_into
    effect.GameEffectComponent.frames = duration
    effect.var_str.basepath = basepath
    effect.var_bool.keep_ui = keep_ui
    effect.var_bool.end_on_death = end_on_death
    effect.var_str.components_file = components_file
    effect:addComponent("LuaComponent", {
        script_source_file = basepath .. "apply.lua",
        execute_on_added = true,
        remove_after_executed = true
    })
end

function polytools.hide(target, duration)
    if type(target) == "number" then
        target = Entity(target)
    end
    if not target or not target:alive() then
        print_error("Attempted to polysave an entity that doesn't exist")
        return
    end
    local proj = target.ProjectileComponent
    if proj and proj.on_death_explode then
        proj.on_death_explode = false
        target:addComponent("LuaComponent", {
            script_source_file = basepath .. "fix_projectiles.lua",
            execute_every_n_frame = 1,
            remove_after_executed = true
        })
    end
    local effect = target:addGameEffect(basepath .. "effect_silent.xml")
    effect.GameEffectComponent.polymorph_target = basepath .. "null.xml"
    effect.GameEffectComponent.frames = duration
    effect.var_str.basepath = basepath
    effect:addComponent("LuaComponent", {
        script_source_file = basepath .. "apply.lua",
        execute_on_added = true,
        remove_after_executed = true
    })
    return effect
end

function polytools.save(target)
    return polytools.hide(target, 1).GameEffectComponent.mSerializedData
end

local function BytesToInt(b1, b2, b3, b4, big_endian)
    if big_endian then
        return b1 + b2 * 0x100 + b3 * 0x10000 + b4 * 0x1000000
    else
        return b4 + b3 * 0x100 + b2 * 0x10000 + b1 * 0x1000000
    end
end

function polytools.getPath(target)
    local data = base64.decodeToNumbers(polytools.save(target))
    -- Iterate through the header to get the name and path
    local i = 1
    local namesize = BytesToInt(data[i], data[i + 1], data[i + 2], data[i + 3])
    -- Advance 4 bytes then discard name including null terminator
    i = i + 4 + namesize + 1
    local pathsize = BytesToInt(data[i], data[i + 1], data[i + 2], data[i + 3])
    i = i + 4
    local path = ""
    if pathsize > 0 then
        for j = i, i + pathsize do
            path = path .. string.char(data[j])
            i = j
        end
    end
    return path
end

function polytools.load(target, data)
    polytools.hide(target, 1).GameEffectComponent.mSerializedData = data
end

function polytools.spawn(x, y, data, delay_load)
    local entity = Entity(EntityCreateNew())
    entity:setTransform(x, y)
    if delay_load then
        entity.var_str.polydata = data
        entity:addComponent("LuaComponent", {
            script_source_file = basepath .. "delay_load.lua",
            execute_every_n_frame = 0
        })
    else
        return polytools.load(entity, data)
    end
end

return polytools
