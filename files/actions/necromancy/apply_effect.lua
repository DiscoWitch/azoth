dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local x, y = self:transform()
local vel = self.VelocityComponent.mVelocity
local r = math.sqrt(vel.x ^ 2 + vel.y ^ 2) / 60 + 5
local r2 = self.ProjectileComponent.config_explosion.explosion_radius
r = math.max(r, r2)

local ents = Entity.getInRadius(x, y, r, "mortal")
if not ents then
    return
end
for k, v in ents:ipairs() do
    if v.DamageModelComponent then
        v:addComponent("LuaComponent", {
            execute_every_n_frame = 10,
            script_damage_received = "mods/azoth/files/actions/necromancy/on_death.lua",
            script_source_file = "mods/azoth/files/empty.lua",
            remove_after_executed = true
        })
    end
end
