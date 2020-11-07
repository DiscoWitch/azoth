dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/azoth/files/lib/disco_util.lua")

function TetherConnect(self)
    -- For connecting two ends of tether to each other for pulling
    local rope_last = tonumber(GlobalsGetValue("rope_last", 0))
    if rope_last == self:id() then
        -- A rope can't connect to itself
        return
    end
    if self.var_int.rope_other then
        -- Don't connect ropes that are already connected
        return
    end
    if rope_last ~= 0 and EntityGetIsAlive(rope_last) then
        rope_last = Entity(rope_last)
        -- Connect to the last rope that's waiting for a connection
        self.var_int.rope_other = rope_last:id()
        rope_last.var_int.rope_other = self:id()

        -- Create the tether cable
        local pos_x, pos_y = self:transform()
        local trail = Entity(EntityLoad("mods/azoth/files/actions/tether/tether_trail.xml", pos_x, pos_y))
        trail.var_int.knot1 = self:id()
        trail.var_int.knot2 = rope_last:id()

        -- Turn on tether effects; turn off disconnected effects
        self:setEnabledWithTag("no_connect", false)
        rope_last:setEnabledWithTag("no_connect", false)
        self:setEnabledWithTag("connect", true)
        rope_last:setEnabledWithTag("connect", true)
        GlobalsSetValue("rope_last", 0)
    else
        -- If there's nothing to connect to, wait for another rope
        GlobalsSetValue("rope_last", self:id())
    end
end

function TetherPull(self, rope_other, parent)
    local pos_x, pos_y = parent:transform()
    local conn_x, conn_y = rope_other:transform()
    local dist_x = pos_x - conn_x
    local dist_y = pos_y - conn_y
    local dist = math.sqrt(dist_x ^ 2 + dist_y ^ 2)
    local dist_max = self.var_float.dist_max or 50
    local dist_snap = 500
    local pull_force = 0.5
    local drag = 0.05
    if dist > dist_snap then
        -- Beyond the maximum allowed distance, just snap the tether
        self:kill()
        return
    end
    if dist > dist_max then
        -- Different objects use different versions of the PBC so get whichever exists
        local pbc = parent.PhysicsBodyComponent or parent.PhysicsBody2Component
        local cdc = parent.CharacterDataComponent
        if pbc then
            local prev_x = self.var_float.prev_x or pos_x
            local prev_y = self.var_float.prev_y or pos_y
            -- For physics bodies: apply a force to pull them
            local vx = (pos_x - prev_x) * 60
            local vy = (pos_y - prev_y) * 60
            parent:applyForce(-pull_force * dist_x - drag * vx, -pull_force * dist_y - drag * vy)
        elseif cdc then
            -- For creatures: modify velocity each frame to pull them to the rope
            local vel = cdc.mVelocity
            cdc.mVelocity = {
                x = vel.x * (1 - drag) - dist_x,
                y = vel.y * (1 - drag) - dist_y
            }
            cdc.mCollidedHorizontally = true
        else
            -- Teleport the parent to the end of the rope if all other options fail
            local new_x = conn_x + dist_x * dist_max / dist
            local new_y = conn_y + dist_y * dist_max / dist
            parent:setTransform(new_x, new_y)
        end
    end
end

function CanAttach(target)
    if not EntityGetIsAlive(target) then
        return false
    elseif IsPlayer(target) then
        return false
    elseif EntityHasTag(target, "rope") then
        return false
    elseif EntityHasTag(target, "mortal") then
        return true
    elseif EntityHasTag(target, "hittable") then
        return true
    elseif EntityHasTag(target, "tablet") then
        return true
    elseif EntityHasTag(target, "item_physics") then
        return true
    end
    return false
end

function collision_trigger(colliding_entity_id)
    local self = Entity(GetUpdatedEntityID())
    if self.var_bool.attached then
        -- Don't attach if we're already attached to something
        return
    end
    colliding_entity_id = EntityGetRootEntity(colliding_entity_id)
    if CanAttach(colliding_entity_id) then
        self.var_bool.attached = true
        self:setParent(colliding_entity_id)
        self.VelocityComponent.gravity_y = 0
        self.VelocityComponent.mVelocity = {
            x = 0,
            y = 0
        }
        self:setEnabledWithTag("in_flight", false)
        self:setEnabledWithTag("no_connect", true)
        TetherConnect(self)
    end
end

function AttachNearby(self, pos_x, pos_y, attach_world, try_connect)
    attach_world = attach_world or false
    try_connect = try_connect or false
    local attach_radius = 10
    for _, value in ipairs(EntityGetInRadius(pos_x, pos_y, attach_radius)) do
        if CanAttach(EntityGetRootEntity(value)) then
            self:setParent(EntityGetRootEntity(value))
            self.var_bool.attached = true
            break
        end
    end
    if not self.var_bool.attached and attach_world then
        self.var_bool.attached = true
        self:setTransform(pos_x, pos_y, 0, 1, 1)
    end
    if self.var_bool.attached then
        self.VelocityComponent.gravity_y = 0
        self:setEnabledWithTag("in_flight", false)
        self:setEnabledWithTag("no_connect", true)
    end
    if try_connect then
        TetherConnect(self)
    end
end

local self = Entity(GetUpdatedEntityID())
self.var_int.fired_frame = self.var_int.fired_frame or GameGetFrameNum()
local attached = self.var_bool.attached or false
if attached then
    local rope_other = self.var_int.rope_other
    if rope_other then
        if EntityGetIsAlive(rope_other) then
            rope_other = Entity(rope_other)
            -- Face the other end of the rope for particle alignment
            local x, y = rope_other:transform()
            self:setFacing(x, y)
            local parent = self:parent()
            if parent then
                -- If there's a parent entity, pull on it
                TetherPull(self, rope_other, parent)
            end
        else
            -- The rope has broken
            self:kill()
            return
        end
    end
else
    -- Check for collisions to see if we need to attach to terrain
    local pos_x, pos_y = self:transform()
    local vel = self.VelocityComponent.mVelocity
    if GameGetFrameNum() > self.var_int.fired_frame and vel.x == 0 and vel.y == 0 then
        AttachNearby(self, pos_x, pos_y, true, true)
    end
    local hit, hx, hy = RaytraceSurfaces(pos_x, pos_y, pos_x + vel.x / 60, pos_y + vel.y / 60)
    if hit then
        AttachNearby(self, hx, hy, true, true)
    end
end
