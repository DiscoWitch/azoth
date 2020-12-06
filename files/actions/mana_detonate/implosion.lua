dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()

local proj = self.ProjectileComponent
local power = self.var_float.mana_power

local radius = power / 10
self.BlackHoleComponent.radius = radius
self.BlackHoleComponent.particle_attractor_force = radius / 5

local emitter = self:children():search(function(ent) return ent:name() == "emitter" end)
local pec = emitter.ParticleEmitterComponent
pec.x_pos_offset_min = radius * 0.8
pec.x_pos_offset_max = radius
pec.y_pos_offset_min = -radius / 180
pec.y_pos_offset_max = radius / 180

local speed = math.sqrt(pec.attractor_force) * radius
pec.y_vel_min = speed * 0.8
pec.y_vel_max = speed * 0.8
