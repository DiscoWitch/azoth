dofile_once("mods/azoth/files/lib/disco_util.lua")
local polytools = dofile_once("mods/azoth/files/lib/polytools/polytools.lua")

local self = Entity.Current()

if not self.var_str.larpa_data then return end
if self.var_bool.larpa_stop then return end

local x, y, angle = self:transform()
local cx, cy = GameGetCameraPos()
local kill_dist = 300
if (x - cx) ^ 2 + (y - cy) ^ 2 > kill_dist ^ 2 then return end

local vel = self.VelocityComponent.mVelocity
local bounce_angle = 15 * math.pi / 180
angle = 180 + angle + (math.random() - 0.5) * bounce_angle
local speed_min = self.ProjectileComponent.speed_min
local speed_max = self.ProjectileComponent.speed_max
local newspeed = speed_min + math.random() * (speed_max - speed_min)
x = x + 10 * math.cos(angle)
y = y + 10 * math.sin(angle)
vel.x = newspeed * math.cos(angle)
vel.y = newspeed * math.sin(angle)
local data = Entity(EntityCreateNew("larpa_storage"))
data:setTransform(x, y)
data.var_float.vx = vel.x
data.var_float.vy = vel.y
data.var_str.larpa_data = self.var_str.larpa_data
polytools.spawn(x, y, data.var_str.larpa_data, true)
