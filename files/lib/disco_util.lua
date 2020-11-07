function WrapList(list, wrapper, args)
    if not list or #list == 0 then
        return nil
    end
    local wrapped = {}
    function wrapped:len()
        return #list
    end
    function wrapped:ipairs()
        local i = 0
        local n = self:len()
        return function()
            i = i + 1
            if i <= n then
                return i, self[i]
            end
        end
    end
    setmetatable(wrapped, {
        __index = function(self, key)

            if type(key) == "number" then
                return wrapper(list[key], args)
            else
                -- If addressed directly, assume the user wants the first entry
                return wrapper(list[1], args)[key]
            end
        end,
        __newindex = function(self, key, value)
            if type(key) == "number" then
                -- Don't allow writing to the component list
            else
                -- If addressed directly, assume the user wants the first entry
                wrapper(list[1], args)[key] = value
            end
        end,
        __tostring = function(self)
            local output = "List: "
            for k, v in self:ipairs() do
                output = output .. "\n - " .. tostring(v)
            end
            return output
        end
    })
    return wrapped
end

function Entity(entity_id)
    if type(entity_id) ~= "number" or entity_id == 0 then
        return nil
    end
    local ent = {}
    function ent:id()
        return entity_id
    end
    function ent:name()
        return EntityGetName(entity_id)
    end
    function ent:setName(name)
        return EntitySetName(entity_id, name)
    end
    function ent:alive()
        return EntityGetIsAlive(entity_id)
    end
    function ent:kill()
        EntityKill(entity_id)
    end
    function ent:transform()
        return EntityGetTransform(entity_id)
    end
    function ent:setTransform(x, y, angle, scale_x, scale_y)
        return EntitySetTransform(entity_id, x, y, angle, scale_x, scale_y)
    end
    function ent:setFacing(tx, ty)
        local x, y = EntityGetTransform(entity_id)
        local angle = math.atan2(ty - y, tx - x)
        return EntitySetTransform(entity_id, x, y, angle)
    end
    function ent:tags()
        return EntityGetTags(entity_id)
    end
    function ent:hasTag(tag)
        return EntityHasTag(entity_id, tag)
    end
    function ent:addComponent(type, values)
        EntityAddComponent2(entity_id, type, values)
    end
    function ent:allComponents()
        return EntityGetAllComponents(entity_id)
    end
    function ent:parent()
        return Entity(EntityGetParent(entity_id))
    end
    function ent:setParent(parent)
        if type(parent) == "number" then
            EntityAddChild(parent, entity_id)
        else
            EntityAddChild(parent:id(), entity_id)
        end
    end
    function ent:root()
        return Entity(EntityGetRootEntity(entity_id))
    end
    function ent:children()
        return WrapList(EntityGetAllChildren(entity_id), Entity)
    end
    function ent:childrenUnwrapped()
        return EntityGetAllChildren(entity_id)
    end
    function ent:setEnabledWithTag(tag, enabled)
        EntitySetComponentsWithTagEnabled(entity_id, tag, enabled)
    end
    function ent:findChildren(pred)
        local children = {}
        for k, v in ipairs(EntityGetAllChildren(entity_id)) do
            if pred(Entity(v)) then
                table.insert(children, v)
            end
        end
        return WrapList(children, Entity)
    end
    function ent:findChildrenUnwrapped(pred)
        local children = {}
        for k, v in ipairs(EntityGetAllChildren(entity_id)) do
            if pred(v) then
                table.insert(children, v)
            end
        end
        return WrapList(children, Entity)
    end
    function ent:applyForce(fx, fy)
        PhysicsApplyForce(entity_id, fx, fy)
    end
    function ent:applyTorque(tz)
        PhysicsApplyTorque(entity_id, tz)
    end

    local ent_values_special = {
        variables = function(entity_id)
            return Variables(entity_id, "value_string")
        end,
        var_str = function(entity_id)
            return Variables(entity_id, "value_string")
        end,
        var_int = function(entity_id)
            return Variables(entity_id, "value_int")
        end,
        var_bool = function(entity_id)
            return Variables(entity_id, "value_bool")
        end,
        var_float = function(entity_id)
            return Variables(entity_id, "value_float")
        end
    }

    setmetatable(ent, {
        __index = function(self, key)
            if ent_values_special[key] then
                return ent_values_special[key](entity_id)
            else
                return WrapList(EntityGetComponentIncludingDisabled(entity_id, key), Component, entity_id)
            end
        end,
        __newindex = function(self, key, value)
            -- Don't allow writing to the component table
        end,
        __tostring = function(self)
            return "Entity (" .. tostring(entity_id) .. ")"
        end
    })
    return ent
end

function Component(component_id, entity_id)
    local comp = {}
    function comp:id()
        return component_id
    end
    function comp:type()
        return ComponentGetTypeName(component_id)
    end
    function comp:hasTag()
        return ComponentHasTag(component_id)
    end
    function comp:addTag()
        return ComponentAddTag(component_id)
    end
    function comp:removeTag()
        return ComponentRemoveTag(component_id)
    end
    function comp:members()
        return ComponentGetMembers(component_id)
    end

    if ComponentGetTypeName(component_id) == "PhysicsBodyComponent" then
        function comp:getVelocity()
            return PhysicsGetComponentVelocity(entity_id, component_id)
        end
        function comp:getAngularVelocity()
            return PhysicsGetComponentAngularVelocity(entity_id, component_id)
        end
    end

    local comp_getters_special = {
        AbilityComponent = {
            gun_config = MetaObject,
            gunaction_config = MetaObject
        },
        CharacterDataComponent = {
            mVelocity = GetVec2
        },
        ControlsComponent = {
            mAimingVectorNormalized = GetVec2
        },
        ItemComponent = {
            inventory_slot = GetVec2
        },
        LaserEmitterComponent = {
            laser = MetaObject
        },
        ParticleEmitterComponent = {
            mExPosition = GetVec2,
            offset = GetVec2,
            gravity = GetVec2
        },
        PhysicsBody2Component = {
            mLocalPosition = GetVec2
        },
        VelocityComponent = {
            mVelocity = GetVec2
        }
    }

    local comp_setters_special = {
        CharacterDataComponent = {
            mVelocity = SetVec2
        },
        ItemComponent = {
            inventory_slot = SetVec2
        },
        ParticleEmitterComponent = {
            mExPosition = SetVec2,
            offset = SetVec2,
            gravity = SetVec2
        },
        VelocityComponent = {
            mVelocity = SetVec2
        }
    }

    setmetatable(comp, {
        __index = function(self, key)
            if comp_getters_special[self:type()] and comp_getters_special[self:type()][key] then
                return comp_getters_special[self:type()][key](component_id, key)
            else
                return ComponentGetValue2(component_id, key)
            end
        end,
        __newindex = function(self, key, value)
            if comp_setters_special[self:type()] and comp_setters_special[self:type()][key] then
                comp_setters_special[self:type()][key](component_id, key, value)
            else
                ComponentSetValue2(component_id, key, value)
            end
        end,
        __tostring = function(self)
            return self:type() .. "(" .. tostring(component_id) .. ")"
        end
    })
    return comp
end

function Variables(entity_id, type)
    local var = {}
    function var:delete(key)
        local v = EntityGetFirstComponentIncludingDisabled(entity_id, "VariableStorageComponent", key)
        EntityRemoveComponent(entity_id, v)
    end
    setmetatable(var, {
        __index = function(self, key)
            local v = EntityGetFirstComponentIncludingDisabled(entity_id, "VariableStorageComponent", key)
            if v == nil or v == 0 then
                return nil
            else
                return ComponentGetValue2(v, type)
            end
        end,
        __newindex = function(self, key, value)
            local v = EntityGetFirstComponentIncludingDisabled(entity_id, "VariableStorageComponent", key)
            if v == nil or v == 0 then
                v = EntityAddComponent2(entity_id, "VariableStorageComponent", {
                    _tags = key .. ",enabled_in_world,enabled_in_hand,enabled_in_inventory"
                })
            end
            ComponentSetValue2(v, type, value)
        end,
        __len = function(self)
            return #EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
        end
    })
    return var
end

function MetaObject(component_id, obj_name)
    local mo = {}
    function mo:type()
        return ComponentGetTypeName(component_id) .. "." .. obj_name
    end
    setmetatable(mo, {
        __index = function(self, key)
            return ComponentObjectGetValue2(component_id, obj_name, key)
        end,
        __newindex = function(self, key, value)
            ComponentObjectSetValue2(component_id, obj_name, key, value)
        end,
        __tostring = function(self)
            return self:type() .. "(" .. tostring(component_id) .. ")"
        end
    })
    return mo
end

function GetVec2(component_id, key)
    local x, y = ComponentGetValue2(component_id, key)
    return {
        x = x,
        y = y
    }
end
function SetVec2(component_id, key, value)
    ComponentSetValue2(component_id, key, value.x, value.y)
end

function WandCopy(from, to)
    local names_ac = {"ui_name", "mana_max", "mana", "mana_charge_speed"}
    local names_gunconfig = {"reload_time", "actions_per_round", "deck_capacity", "shuffle_deck_when_empty"}
    local names_gunactionconfig = {"fire_rate_wait", "spread_degrees", "speed_multiplier"}
    local fromac = from.AbilityComponent
    local toac = to.AbilityComponent
    for index, name in ipairs(names_ac) do
        toac[name] = fromac[name]
    end
    for index, name in ipairs(names_gunconfig) do
        toac.gun_config[name] = fromac.gun_config[name]
    end
    for index, name in ipairs(names_gunactionconfig) do
        toac.gunaction_config[name] = fromac.gunaction_config[name]
    end
end

function GetSpells(wand)
    local cards = wand:findChildren(function(ent)
        return ent:hasTag("card_action") and not ent.ItemComponent.permanently_attached
    end)
    local always_cast = wand:findChildren(function(ent)
        return ent:hasTag("card_action") and ent.ItemComponent.permanently_attached
    end)
    return cards, always_cast
end

