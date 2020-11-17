dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local now = GameGetFrameNum()
local phase = self.var_int.phase
if phase == nil then
    return
elseif phase == 0 then
    phase = 1
    self.var_int.phase = 1
    self.var_int.phase_change_frame = now + 60 - (now % 30)
end

local x, y = self:transform()
local mass = self.VelocityComponent.mass
local g = 9.8 * 5
local antigrav = -g * mass
local drag = 10 * mass

function phaseStop()
    -- Come to rest in midair shortly after throwing
    local pbc = self.PhysicsBodyComponent
    local vel = pbc:getVelocity()
    self:applyForce(-drag * vel.x, -drag * vel.y + antigrav)
    local angvel = pbc:getAngularVelocity()
    self:applyTorque(-angvel)
    if now >= self.var_int.phase_change_frame then
        self.var_int.phase = 2
        self.var_int.phase_change_frame = now + 4 * 60
    end
end

function phaseSpin()
    -- spend 4 seconds spinning
    local vel = self.PhysicsBodyComponent:getVelocity()
    self:applyForce(-drag * vel.x, -drag * vel.y + antigrav)
    self:applyTorque(mass * 2)

    local vac_count = 180
    local vac_speed = 100

    if now % 60 == 0 then
        for i = 1, vac_count do
            local a = i * 2 * math.pi / vac_count
            local proj = shoot_projectile(self:id(), "mods/azoth/files/items/lodestone/lodestone_vacuum.xml", x, y,
                             vac_speed * math.cos(a), vac_speed * math.sin(a), true)
        end
    end
    if now >= self.var_int.phase_change_frame then
        self.var_int.phase = 3
    end
end

function phaseReleaseGold()
    -- Keep spinning while spraying gold
    local pbc = self.PhysicsBodyComponent
    local vel = pbc:getVelocity()
    self:applyForce(-drag * vel.x, -drag * vel.y + antigrav)
    self:applyTorque(mass * 2)

    local my_money = self.WalletComponent.money
    if my_money > 0 then
        local spray_amt = math.min(my_money, 10)
        local angle = 24 * now * (math.pi / 180)
        local gold_speed = 300
        local gold_offset = 7
        GameCreateParticle("gold", x + gold_offset * math.cos(angle), y + gold_offset * math.sin(angle), spray_amt,
            gold_speed * math.cos(angle), gold_speed * math.sin(angle), false, false)
        self.WalletComponent.money = my_money - spray_amt
    else
        self.var_int.phase = 4
        self.var_int.phase_change_frame = now + 1 * 60
    end
end

function phaseLaunch()
    for k, v in self.ParticleEmitterComponent:ipairs() do
        v.mExPosition = {
            x = x,
            y = y
        }
    end
    -- Find the nearest treasure and launch at it
    local target = EntityGetClosestWithTag(x, y, "chest")
    local dist = math.huge
    if target ~= 0 then
        local tx, ty = EntityGetTransform(target)
        dist = math.sqrt((tx - x) ^ 2 + (ty - y) ^ 2)
    end
    local heart_candidates = EntityGetWithTag("drillable")
    local heart_dist = math.huge
    local heart = 0
    for k, v in ipairs(heart_candidates) do
        local uicomp = EntityGetFirstComponent(v, "UIInfoComponent")
        if uicomp and string.match(ComponentGetValue2(uicomp, "name"), "heart") then
            local hx, hy = EntityGetTransform(v)
            local hdist = math.sqrt((hx - x) ^ 2 + (hy - y) ^ 2)
            if hdist < dist then
                dist = hdist
                target = v
            end
        end
    end
    if target ~= 0 then
        local launch_speed = 1000
        local tx, ty = EntityGetTransform(target)
        local dx = tx - x
        local dy = ty - y

        self:setEnabledWithTag("disabled_in_flight", false)
        self:setEnabledWithTag("enabled_in_flight", true)
        self.VelocityComponent.mVelocity = {
            x = launch_speed * dx / dist,
            y = launch_speed * dy / dist
        }
    end
    self.var_int.phase = 5
    self.var_int.phase_change_frame = now + 20
end

function phaseFinal()
    if now >= self.var_int.phase_change_frame then
        self.var_int:delete("phase")
        self:setEnabledWithTag("disabled_in_flight", true)
        self:setEnabledWithTag("enabled_in_flight", false)
        self:setEnabledWithTag("disabled_during_throw", true)
        local vel = self.VelocityComponent.mVelocity
        self:applyForce(-vel.x / 2, -vel.y / 2)
    end
end

local phases = {phaseStop, phaseSpin, phaseReleaseGold, phaseLaunch, phaseFinal}
phases[phase]()
