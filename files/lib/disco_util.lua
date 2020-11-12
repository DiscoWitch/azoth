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
    function wrapped:searchList(pred)
        local output = {}
        for i = 1, #list do
            if pred(wrapper(list[i], args)) then
                table.insert(output, list[i])
            end
        end
        return WrapList(output, wrapper, args)
    end
    function wrapped:searchListRaw(pred)
        -- Does not wrap list entries during the search
        local output = {}
        for i = 1, #list do
            if pred(list[i]) then
                table.insert(output, list[i])
            end
        end
        return WrapList(output, wrapper, args)
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

local ent_values_special = {
    variables = function(eid)
        return Variable(eid, "value_string")
    end,
    var_str = function(eid)
        return Variable(eid, "value_string")
    end,
    var_int = function(eid)
        return Variable(eid, "value_int")
    end,
    var_bool = function(eid)
        return Variable(eid, "value_bool")
    end,
    var_float = function(eid)
        return Variable(eid, "value_float")
    end
}

Entity = {}
Entity.__cache = {}
Entity.__mt = {
    __tostring = function(self)
        return "Class: Entity"
    end,
    __call = function(self, id)
        if not id or id == 0 then
            return nil
        end
        if not Entity.__cache[id] then
            Entity.__cache[id] = {
                __id = id
            }
            setmetatable(Entity.__cache[id], Entity)
        end
        return Entity.__cache[id]
    end
}
Entity.__index = function(self, key)
    if Entity[key] then
        return Entity[key]
    end
    if key == "__id" then
        print_error("Illegal Entity ID")
        return 0
    end
    if ent_values_special[key] then
        return ent_values_special[key](self.__id)
    else
        return WrapList(EntityGetComponentIncludingDisabled(self.__id, key), Component, self.__id)
    end
end
Entity.__newindex = function(self, key, value)
    print_error("Can't set entity values")
end
Entity.__tostring = function(self)
    return "Entity (" .. self.__id .. ")"
end
function Entity:id()
    return self.__id
end
function Entity:name()
    return EntityGetName(self.__id)
end
function Entity:setName(name)
    return EntitySetName(self.__id, name)
end
function Entity:alive()
    return EntityGetIsAlive(self.__id)
end
function Entity:kill()
    EntityKill(self.__id)
end
function Entity:transform()
    return EntityGetTransform(self.__id)
end
function Entity:setTransform(x, y, angle, scale_x, scale_y)
    return EntitySetTransform(self.__id, x, y, angle, scale_x, scale_y)
end
function Entity:setFacing(tx, ty)
    local x, y = EntityGetTransform(self.__id)
    local angle = math.atan2(ty - y, tx - x)
    return EntitySetTransform(self.__id, x, y, angle)
end
function Entity:tags()
    return EntityGetTags(self.__id)
end
function Entity:hasTag(tag)
    return EntityHasTag(self.__id, tag)
end
function Entity:addTag(tag)
    EntityAddTag(self.__id, tag)
end
function Entity:removeTag(tag)
    EntityRemoveTag(self.__id, tag)
end

-- Component functions
function Entity:addComponent(ctype, values)
    EntityAddComponent2(self.__id, ctype, values)
end
function Entity:allComponents()
    return WrapList(EntityGetAllComponents(self.__id), Component, self.__id)
end
function Entity:componentsWithTag(ctype, tag)
    return WrapList(EntityGetComponentIncludingDisabled(self.__id, ctype, tag), Component, self.__id)
end

function Entity:setEnabledWithTag(tag, enabled)
    EntitySetComponentsWithTagEnabled(self.__id, tag, enabled)
end
function Entity:loadComponents(filename, load_children)
    EntityLoadToEntity(filename, self.__id)
    if load_children then
        local x, y = EntityGetTransform(self.__id)
        local surrogate = EntityLoad(filename, x, y)
        local children = EntityGetAllChildren(surrogate)
        if children then
            for k, v in ipairs(children) do
                EntityRemoveFromParent(v)
                EntityAddChild(self.__id, v)
            end
        end
        EntityKill(surrogate)
    end
end
function Entity:removeComponents(types)
    if type(types) == "string" then
        local comps = self[types]
        if comps then
            for _, v in comps:ipairs() do
                v:remove()
            end
        end
    else
        for _, v in ipairs(types) do
            self:removeComponents(v)
        end
    end
end
-- Parent/child hierarchy
function Entity:parent()
    return Entity(EntityGetParent(self.__id))
end
function Entity:setParent(parent)
    if type(parent) == "number" then
        EntityAddChild(parent, self.__id)
    else
        EntityAddChild(parent:id(), self.__id)
    end
end
function Entity:root()
    return Entity(EntityGetRootEntity(self.__id))
end
function Entity:children()
    return WrapList(EntityGetAllChildren(self.__id), Entity)
end
function Entity:childrenUnwrapped()
    return EntityGetAllChildren(self.__id)
end
function Entity:findChildren(pred)
    local output = {}
    local children = EntityGetAllChildren(self.__id)
    if children then
        for k, v in ipairs(children) do
            if pred(Entity(v)) then
                table.insert(output, v)
            end
        end
    end
    return WrapList(output, Entity)
end
function Entity:findChildrenUnwrapped(pred)
    local output = {}
    local children = EntityGetAllChildren(self.__id)
    if children then
        for k, v in ipairs(children) do
            if pred(v) then
                table.insert(output, v)
            end
        end
    end
    return WrapList(output, Entity)
end
-- Misc Gameplay
function Entity:addStains(material, amount)
    if type(material) == "string" then
        material = CellFactory_GetType(material)
    end
    EntityAddRandomStains(self.__id, material, amount)
end
function Entity:addGameEffect(filename)
    return Entity(LoadGameEffectEntityTo(self.__id, filename))
end

-- Physics functions
function Entity:applyForce(fx, fy)
    if self.PhysicsBodyComponent or self.PhysicsBody2Component then
        PhysicsApplyForce(self.__id, fx, fy)
    elseif self.VelocityComponent then
        local vel = self.VelocityComponent.mVelocity
        vel.x = vel.x + fx / 60
        vel.y = vel.y + fy / 60
        self.VelocityComponent.mVelocity = vel
    else
        print_error("Tried to apply a force to an object with no physics or velocity component")
    end
end
function Entity:applyTorque(tz)
    PhysicsApplyTorque(self.__id, tz)
end
setmetatable(Entity, Entity.__mt)

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

MetaObject = {}
MetaObject.__mt = {
    __call = function(self, c_id, obj_name)
        if not c_id or c_id == 0 or not obj_name then
            return nil
        end
        local output = {
            __id = c_id,
            __name = obj_name
        }
        setmetatable(output, MetaObject)
        return output
    end
}
MetaObject.__index = function(self, key)
    return ComponentObjectGetValue2(self.__id, self.__name, key)
end
MetaObject.__newindex = function(self, key, value)
    ComponentObjectSetValue2(self.__id, self.__name, key, value)
end
setmetatable(MetaObject, MetaObject.__mt)

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
    DamageModelComponent = {
        damage_multipliers = MetaObject
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

Component = {}
Component.__cache = {}
Component.__mt = {
    __tostring = function(self)
        return "Class: Component"
    end,
    __call = function(self, c_id, e_id)
        if not c_id or c_id == 0 or not e_id or e_id == 0 then
            return nil
        end
        if not Component.__cache[e_id] then
            Component.__cache[e_id] = {}
        end
        if not Component.__cache[e_id][c_id] then
            Component.__cache[e_id][c_id] = {
                __id = c_id,
                __entity = e_id
            }
            setmetatable(Component.__cache[e_id][c_id], Component)
        end
        return Component.__cache[e_id][c_id]
    end
}
Component.__index = function(self, key)
    if Component[key] then
        return Component[key]
    end
    if key == "__id" then
        print_error("Illegal Component ID")
        return 0
    end
    if comp_getters_special[self:type()] and comp_getters_special[self:type()][key] then
        return comp_getters_special[self:type()][key](self.__id, key)
    else
        return ComponentGetValue2(self.__id, key)
    end
end
Component.__newindex = function(self, key, value)
    if key == "__id" then
    elseif comp_setters_special[self:type()] and comp_setters_special[self:type()][key] then
        comp_setters_special[self:type()][key](self.__id, key, value)
    else
        ComponentSetValue2(self.__id, key, value)
    end
end
Component.__tostring = function(self)
    return self:type() .. " (" .. tostring(self.__id) .. ")"
end
function Component:id()
    return self.__id
end
function Component:type()
    return ComponentGetTypeName(self.__id)
end
function Component:hasTag()
    return ComponentHasTag(self.__id)
end
function Component:addTag()
    return ComponentAddTag(self.__id)
end
function Component:removeTag()
    return ComponentRemoveTag(self.__id)
end
function Component:members()
    return ComponentGetMembers(self.__id)
end
function Component:enabled()
    return ComponentGetIsEnabled(self.__id)
end
function Component:setEnabled(value)
    EntitySetComponentIsEnabled(self.__entity, self.__id, value)
end
function Component:remove()
    EntityRemoveComponent(self.__entity, self.__id)
end
function Component:getVelocity()
    local vx, vy = PhysicsGetComponentVelocity(self.__entity, self.__id)
    return {
        x = vx,
        y = vy
    }
end
function Component:getAngularVelocity()
    return PhysicsGetComponentAngularVelocity(self.__entity, self.__id)
end

setmetatable(Component, Component.__mt)

Variable = {}
Variable.__cache = {}
Variable.__mt = {
    __call = function(self, e_id, var_type)
        if not e_id or e_id == 0 or not var_type then
            return nil
        end
        local output = {
            __id = e_id,
            __type = var_type
        }
        if not Variable.__cache[e_id] then
            Variable.__cache[e_id] = {}
        end
        setmetatable(output, Variable)
        return output
    end
}
Variable.__index = function(self, key)
    if Variable[key] then
        return Variable[key]
    end
    if not Variable.__cache[self.__id][key] then
        local vars = EntityGetComponentIncludingDisabled(self.__id, "VariableStorageComponent")
        if vars then
            for k, v in ipairs(vars) do
                Variable.__cache[self.__id][ComponentGetValue2(v, "name")] = v
            end
        end
    end
    local v = Variable.__cache[self.__id][key]
    if not v then
        return nil
    else
        return ComponentGetValue2(v, self.__type)
    end
end
Variable.__newindex = function(self, key, value)
    if not Variable.__cache[self.__id][key] then
        local vars = EntityGetComponentIncludingDisabled(self.__id, "VariableStorageComponent")
        if vars then
            for k, v in ipairs(vars) do
                Variable.__cache[self.__id][ComponentGetValue2(v, "name")] = v
            end
        end
    end
    if not Variable.__cache[self.__id][key] then
        Variable.__cache[self.__id][key] = EntityAddComponent2(self.__id, "VariableStorageComponent", {
            name = key
        })
    end
    ComponentSetValue2(Variable.__cache[self.__id][key], self.__type, value)
end

function Variable:delete(key)
    local v = EntityGetFirstComponentIncludingDisabled(self.__id, "VariableStorageComponent", key)
    EntityRemoveComponent(self.__id, v)
end

setmetatable(Variable, Variable.__mt)

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
