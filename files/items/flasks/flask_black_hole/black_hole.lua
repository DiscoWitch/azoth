dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
dofile_once("data/scripts/lib/utilities.lua")

local self = Entity.Current()
local now = GameGetFrameNum()
local start = self.var_int.start_frame or now
if start == now then
    self.var_int.start_frame = start
    local x, y = self:transform()
    for i = 1, 60 do
        local proj = Entity.Load("mods/azoth/files/items/flasks/flask_black_hole/projectile.xml")
        proj:setParent(self)
    end
    return
end

local max_radius = 64
local max_time = 300
local t = math.min((now - start) / max_time, 1)

local bhc = self.BlackHoleComponent
local radius = math.max(t * max_radius, 1)

bhc.radius = radius
bhc.particle_attractor_force = bhc.radius * 0.25

self.ParticleEmitterComponent:search(function(comp)
    return comp.emitted_material_name == "spark_white_bright"
end).area_circle_radius = {x = radius, y = radius}

