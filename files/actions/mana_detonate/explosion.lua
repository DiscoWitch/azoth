dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()

local proj = self.ProjectileComponent
local power = proj.config.action_mana_drain
local explosion = proj.config_explosion
explosion.explosion_radius = math.min(power / 10, 300)
-- explosion.max_durability_to_destroy = 20
explosion.max_durability_to_destroy = power / 50
explosion.ray_energy = 16 * power ^ 2
local material = "smoke"

if power < 100 then
    material = "smoke"
elseif power < 500 then
    material = "fire"
    explosion.audio_event_name = "explosions/magic_rocket_mid"
else
    -- explosion.audio_enabled = false
    explosion.audio_event_name = "explosions/magic_rocket_big"
    explosion.create_cell_probability = 1000 / power
    material = "fire_blue"
end
explosion.create_cell_material = material

if power > 900 then
    local x, y = self:transform()
    local implosion = Entity.Load("mods/azoth/files/actions/mana_detonate/implosion.xml", x, y)
    implosion.var_float.mana_power = power
end
