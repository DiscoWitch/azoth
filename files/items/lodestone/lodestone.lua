dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/azoth/files/lib/goki_variables.lua")

function init(self)
    local x, y = EntityGetTransform(self)
    SetRandomSeed(x, y)
end

local self = GetUpdatedEntityID()
local x, y = EntityGetTransform(self)
local throw_frame = EntityGetVariableNumber(self, "throw_frame", -1)
if throw_frame == -1 then
    return
end
local vc = EntityGetFirstComponent(self, "VelocityComponent")
local mass = ComponentGetValue2(vc, "mass")
local cur_frame = GameGetFrameNum()
local airtime = cur_frame - throw_frame
local pbc = EntityGetFirstComponent(self, "PhysicsBodyComponent")

local g = 9.8 * 5
local antigrav = -g * mass
-- We want a very large drag to make it float in place
local drag = 10 * mass

if airtime < 60 then
    local vx, vy = PhysicsGetComponentVelocity(self, pbc)
    PhysicsApplyForce(self, -drag * vx, -drag * vy + antigrav)
    local angvel = PhysicsGetComponentAngularVelocity(self, pbc)
    PhysicsApplyTorque(self, -angvel)
elseif airtime < 300 then
    local vx, vy = PhysicsGetComponentVelocity(self, pbc)
    PhysicsApplyForce(self, -drag * vx, -drag * vy + antigrav)
    local angvel = PhysicsGetComponentAngularVelocity(self, pbc)
    PhysicsApplyTorque(self, mass * 2)

    local angle = 2 * math.pi * Random()
    local vx = math.cos(angle)
    local vy = math.sin(angle)
    shoot_projectile(self, "mods/azoth/files/items/lodestone/lodestone_vacuum.xml", x, y, vx * 800, vy * 800, true)

elseif airtime < 301 then
    local treasure = EntityGetClosestWithTag(x, y, "chest")
    if treasure ~= 0 then
        local launch_speed = 1000
        local tx, ty = EntityGetTransform(treasure)
        local dx = tx - x
        local dy = ty - y
        local dist = math.sqrt(dx ^ 2 + dy ^ 2)
        EntitySetComponentsWithTagEnabled(self, "disabled_in_flight", false)
        EntitySetComponentsWithTagEnabled(self, "enabled_in_flight", true)
        ComponentSetValue2(vc, "mVelocity", launch_speed * dx / dist, launch_speed * dy / dist)
    end

    local my_wallet = EntityGetFirstComponentIncludingDisabled(self, "WalletComponent")
    local my_money = ComponentGetValue2(my_wallet, "money")
    print("I have $" .. my_money)
    GameCreateParticle("gold", x, y, my_money, 0, 50, false, false)
    ComponentSetValue2(my_wallet, "money", 0)
elseif airtime < 310 then
    -- Just a gap to allow for flight time
else
    EntitySetVariableNumber(self, "throw_frame", -1)
    EntitySetComponentsWithTagEnabled(self, "disabled_in_flight", true)
    EntitySetComponentsWithTagEnabled(self, "enabled_in_flight", false)
    local vx, vy = GameGetVelocityCompVelocity(self)
    PhysicsApplyForce(self, -vx, -vy)
end
