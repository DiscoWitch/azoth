dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/azoth/files/lib/goki_variables.lua")

local self = GetUpdatedEntityID()
local now = GameGetFrameNum()
local phase = EntityGetVariableNumber(self, "phase", -1)
if phase == -1 then
    return
elseif phase == 0 then
    EntitySetVariableNumber(self, "phase_change_frame", now + 60 - (now % 30))
end

local x, y = EntityGetTransform(self)
local vc = EntityGetFirstComponent(self, "VelocityComponent")
local mass = ComponentGetValue2(vc, "mass")

local g = 9.8 * 5
local antigrav = -g * mass
local drag = 10 * mass

function phaseStop()
    -- Come to rest in midair shortly after throwing
    local pbc = EntityGetFirstComponent(self, "PhysicsBodyComponent")
    local vx, vy = PhysicsGetComponentVelocity(self, pbc)
    PhysicsApplyForce(self, -drag * vx, -drag * vy + antigrav)
    local angvel = PhysicsGetComponentAngularVelocity(self, pbc)
    PhysicsApplyTorque(self, -angvel)
    if now >= EntityGetVariableNumber(self, "phase_change_frame", 0) then
        EntitySetVariableNumber(self, "phase", 2)
        EntitySetVariableNumber(self, "phase_change_frame", now + 4 * 60)
    end
end

function phaseSpin()
    -- spend 4 seconds spinning
    local pbc = EntityGetFirstComponent(self, "PhysicsBodyComponent")
    local vx, vy = PhysicsGetComponentVelocity(self, pbc)
    PhysicsApplyForce(self, -drag * vx, -drag * vy + antigrav)
    local angvel = PhysicsGetComponentAngularVelocity(self, pbc)
    PhysicsApplyTorque(self, mass * 2)

    if now % 60 == 0 then
        for i = 1, 360 do
            local a = i * math.pi / 180
            local tx = math.cos(a)
            local ty = math.sin(a)
            local vac_speed = 400
            shoot_projectile(self, "mods/azoth/files/items/lodestone/lodestone_vacuum.xml", x, y, tx * vac_speed,
                ty * vac_speed, true)
        end
    end
    if now >= EntityGetVariableNumber(self, "phase_change_frame", 0) then
        EntitySetVariableNumber(self, "phase", 3)
    end
end

function phaseReleaseGold()
    -- Keep spinning while spraying gold
    local pbc = EntityGetFirstComponent(self, "PhysicsBodyComponent")
    local vx, vy = PhysicsGetComponentVelocity(self, pbc)
    PhysicsApplyForce(self, -drag * vx, -drag * vy + antigrav)
    local angvel = PhysicsGetComponentAngularVelocity(self, pbc)
    PhysicsApplyTorque(self, mass * 2)

    local my_wallet = EntityGetFirstComponentIncludingDisabled(self, "WalletComponent")
    local my_money = ComponentGetValue2(my_wallet, "money")
    if my_money > 0 then
        local spray_amt = math.min(my_money, 10)
        local angle = 24 * now * (math.pi / 180)
        local gold_speed = 300
        local gold_offset = 7
        GameCreateParticle("gold", x + gold_offset * math.cos(angle), y + gold_offset * math.sin(angle), spray_amt,
            gold_speed * math.cos(angle), gold_speed * math.sin(angle), false, false)
        ComponentSetValue2(my_wallet, "money", my_money - spray_amt)
    else
        EntitySetVariableNumber(self, "phase", 4)
        EntitySetVariableNumber(self, "phase_change_frame", now + 1 * 60)
    end
end

function phaseLaunch()
    -- Find the nearest treasure and launch at it
    local treasure = EntityGetClosestWithTag(x, y, "chest")
    local heart_candidates = EntityGetWithTag("drillable")
    local heart_dist = math.huge
    local heart = 0
    for k, v in ipairs(heart_candidates) do
        local uicomp = EntityGetFirstComponent(v, "UIInfoComponent")
        if uicomp and string.match(ComponentGetValue2(uicomp, "name"), "heart") then
            local hx, hy = EntityGetTransform(v)
            local dist = math.sqrt((hx - x) ^ 2 + (hy - y) ^ 2)
            if dist < heart_dist then
                heart_dist = dist
                heart = v
            end
        end
    end
    local target = 0
    if treasure == 0 then
        -- No treasure: get heart
        target = heart
    elseif heart == 0 then
        -- No heart: get treasure
        target = treasure
    else
        -- Treasure and heart coexist: get closest
        local tx, ty = EntityGetTransform(treasure)
        local treasure_dist = math.sqrt((tx - x) ^ 2 + (ty - y) ^ 2)
        if treasure_dist < heart_dist then
            target = treasure
        else
            target = heart
        end
    end
    if target ~= 0 then
        local launch_speed = 1000
        local tx, ty = EntityGetTransform(target)
        local dx = tx - x
        local dy = ty - y
        local dist = math.sqrt(dx ^ 2 + dy ^ 2)

        EntitySetComponentsWithTagEnabled(self, "disabled_in_flight", false)
        EntitySetComponentsWithTagEnabled(self, "enabled_in_flight", true)
        ComponentSetValue2(vc, "mVelocity", launch_speed * dx / dist, launch_speed * dy / dist)
    end
    EntitySetVariableNumber(self, "phase", 5)
    EntitySetVariableNumber(self, "phase_change_frame", now + 10)
end

function phaseFinal()
    if now >= EntityGetVariableNumber(self, "phase_change_frame", 0) then
        EntitySetVariableNumber(self, "phase", -1)
        EntitySetComponentsWithTagEnabled(self, "disabled_in_flight", true)
        EntitySetComponentsWithTagEnabled(self, "enabled_in_flight", false)
        local vx, vy = GameGetVelocityCompVelocity(self)
        PhysicsApplyForce(self, -vx, -vy)
    end
end

local phases = {phaseStop, phaseSpin, phaseReleaseGold, phaseLaunch, phaseFinal}
phases[phase]()
