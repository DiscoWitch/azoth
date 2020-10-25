dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/azoth/files/lib/goki_variables.lua")

function TetherConnect(entity)
    -- For connecting two ends of tether to each other for pulling
    local rope_last = tonumber(GlobalsGetValue("rope_last", 0));
    if rope_last == entity then
        -- A rope can't connect to itself
        return
    end

    if EntityGetVariableNumber(entity, "rope_connected", 0) ~= 0 then
        -- Don't connect ropes that are already connected
        return
    end

    if rope_last ~= 0 and EntityGetIsAlive(rope_last) then
        -- Connect to the last rope that's waiting for a connection
        EntitySetVariableNumber(entity, "rope_connected", rope_last)
        EntitySetVariableNumber(rope_last, "rope_connected", entity)
        local pos_x, pos_y = EntityGetTransform(entity)
        local trail = EntityLoad("mods/azoth/files/actions/tether/tether_trail.xml", pos_x, pos_y)
        EntitySetVariableNumber(trail, "knot1", entity)
        EntitySetVariableNumber(trail, "knot2", rope_last)
        EntitySetComponentsWithTagEnabled(entity, "no_connect", false)
        EntitySetComponentsWithTagEnabled(rope_last, "no_connect", false)
        EntitySetComponentsWithTagEnabled(entity, "connect", true)
        EntitySetComponentsWithTagEnabled(rope_last, "connect", true)
        GlobalsSetValue("rope_last", 0);
    else
        -- If there's nothing to connect to, wait for another rope
        GlobalsSetValue("rope_last", entity);
    end
end

function TetherPull(self)
    local parent = EntityGetVariableNumber(self, "rope_parent", 0);
    if not EntityGetIsAlive(parent) then
        EntityKill(self)
        return
    end
    local rope_other = EntityGetVariableNumber(self, "rope_connected", 0);
    if rope_other == 0 then
        -- Just follow the parent
        local pos_x, pos_y = EntityGetTransform(parent)
        EntitySetTransform(self, pos_x, pos_y, 0, 1, 1)
        return
    end
    if not EntityGetIsAlive(rope_other) then
        EntityKill(self)
        return
    end

    local pos_x, pos_y = EntityGetTransform(parent)
    local conn_x, conn_y = EntityGetTransform(rope_other)
    local dist_x = pos_x - conn_x
    local dist_y = pos_y - conn_y
    local dist = math.sqrt(dist_x ^ 2 + dist_y ^ 2)
    local dist_max = EntityGetVariableNumber(self, "rope_length", 50);
    local dist_snap = 500;
    local drag = 0.05;
    if dist > dist_snap then
        -- Beyond the maximum allowed distance, just snap the tether
        EntityKill(self)
        return
    end
    if dist > dist_max then
        -- Different objects use different versions of the PBC so get whichever exists
        local pbc = EntityGetFirstComponent(parent, "PhysicsBodyComponent") or
                        EntityGetFirstComponent(parent, "PhysicsBody2Component");
        local cdc = EntityGetFirstComponent(parent, "CharacterDataComponent")
        if pbc ~= nil then
            -- For physics bodies: apply a force to pull them
            PhysicsApplyForce(parent, -dist_x / 2, -dist_y / 2)
        elseif cdc ~= nil then
            -- For creatures: modify velocity each frame to pull them to the rope
            local vx, vy = ComponentGetValue2(cdc, "mVelocity")
            vx = vx * (1 - drag) - dist_x
            vy = vy * (1 - drag) - dist_y
            ComponentSetValue2(cdc, "mVelocity", vx, vy)
            ComponentSetValue2(cdc, "mCollidedHorizontally", true)

        else
            -- Teleport the parent to the end of the rope if all other options fail
            local new_x = conn_x + dist_x * dist_max / dist
            local new_y = conn_y + dist_y * dist_max / dist
            EntitySetTransform(parent, new_x, new_y)
        end
    end
    -- Follow the parent and face the other end of the rope
    pos_x, pos_y = EntityGetTransform(parent)
    local drctn = -get_direction(conn_x, conn_y, pos_x, pos_y)
    EntitySetTransform(self, pos_x, pos_y, drctn, 1, 1)
end

function CanAttach(target)
    if not EntityGetIsAlive(target) then
        return false;
    elseif IsPlayer(target) then
        return false;
    elseif EntityHasTag(target, "rope") then
        return false;
    elseif EntityHasTag(target, "mortal") then
        return true;
    elseif EntityHasTag(target, "hittable") then
        return true;
    elseif EntityHasTag(target, "tablet") then
        return true;
    elseif EntityHasTag(target, "item_physics") then
        return true;
    end
    return false;
end

function collision_trigger(colliding_entity_id)
    local entity = GetUpdatedEntityID();
    local parent = EntityGetVariableNumber(entity, "rope_parent", 0)
    if parent ~= 0 then
        return
    end
    colliding_entity_id = EntityGetRootEntity(colliding_entity_id)
    if CanAttach(colliding_entity_id) then
        EntitySetVariableNumber(entity, "rope_parent", colliding_entity_id)
        local vc = EntityGetFirstComponent(entity, "VelocityComponent")
        ComponentSetValue2(vc, "gravity_y", 0)
        ComponentSetValue2(vc, "mVelocity", 0, 0)
        EntitySetComponentsWithTagEnabled(entity, "in_flight", false)
        EntitySetComponentsWithTagEnabled(entity, "no_connect", true)
        TetherConnect(entity)
    end
end

function AttachNearby(self, pos_x, pos_y, attach_world, new_home)
    attach_world = attach_world or false
    new_home = new_home or false
    local ents = EntityGetInRadius(pos_x, pos_y, 10)
    local parent = 0
    for key, value in ipairs(ents) do
        if CanAttach(EntityGetRootEntity(value)) then
            parent = EntityGetRootEntity(value)
            break
        end
    end
    if parent == 0 and attach_world then
        parent = -1
        EntitySetTransform(self, pos_x, pos_y)
    end
    EntitySetVariableNumber(self, "rope_parent", parent)
    local vc = EntityGetFirstComponent(self, "VelocityComponent")
    ComponentSetValue2(vc, "gravity_y", 0)
    ComponentSetValue2(vc, "mVelocity", 0, 0)
    EntitySetComponentsWithTagEnabled(self, "in_flight", false)
    EntitySetComponentsWithTagEnabled(self, "no_connect", true)
    if new_home then
        TetherConnect(self)
    end
end

local self = GetUpdatedEntityID();
local parent = EntityGetVariableNumber(self, "rope_parent", 0);
if parent == -1 then
    -- Handle attachment to terrain
    local vc = EntityGetFirstComponent(self, "VelocityComponent")
    ComponentSetValue2(vc, "gravity_y", 0)
    ComponentSetValue2(vc, "mVelocity", 0, 0)
    local rope_other = EntityGetVariableNumber(self, "rope_connected", 0);

    if rope_other ~= 0 then
        if EntityGetIsAlive(rope_other) then
            local pos_x, pos_y = EntityGetTransform(self)
            local conn_x, conn_y = EntityGetTransform(rope_other)
            local drctn = -get_direction(conn_x, conn_y, pos_x, pos_y)
            EntitySetTransform(self, pos_x, pos_y, drctn)
        else
            EntityKill(self)
        end
    end
elseif parent ~= 0 then
    -- Handle attachment to entities
    TetherPull(self)
else
    -- Check for collisions to see if we need to attach to terrain
    local pos_x, pos_y = EntityGetTransform(self)
    local vx, vy = GameGetVelocityCompVelocity(self)
    local hit, hx, hy = RaytraceSurfaces(pos_x, pos_y, pos_x + vx / 60, pos_y + vy / 60)
    if hit then
        AttachNearby(self, hx, hy, true, true)
    end
end
