dofile_once("mods/azoth/files/lib/disco_util.lua")
dofile_once("mods/azoth/files/lib/polysave/polysave.lua")

local self = Entity(GetUpdatedEntityID())
if not self.var_int.larpa_data then
    -- No parent -> stop spawning
    return
end
local data = Entity(self.var_int.larpa_data)
if data and data:alive() then
    if data.var_str.projdata then
        data.var_bool.projdata = true

        local vel = self.VelocityComponent.mVelocity
        local speed_sqr = vel.x ^ 2 + vel.y ^ 2
        if speed_sqr < 25 then
            local x, y = self:transform()
            local found_normal, nx, ny, dist = GetSurfaceNormal(x, y, 5, 8)
            if found_normal then
                local bounce_angle = math.pi
                local angle = math.atan2(ny, nx) + 2 * (math.random() - 0.5) * bounce_angle
                local speed_min = self.ProjectileComponent.speed_min
                local speed_max = self.ProjectileComponent.speed_max
                local newspeed = speed_min + math.random() * (speed_max - speed_min)
                data.var_float.vx = newspeed * math.cos(angle)
                data.var_float.vy = newspeed * math.sin(angle)
            else
                data.var_float.vx = vel.x
                data.var_float.vy = vel.y
            end
            -- set a random speed
            local angle = math.random() * 2 * math.pi

        else
            data.var_float.vx = vel.x
            data.var_float.vy = vel.y
        end

        local x, y = self:transform()
        polyspawn(x, y, data.var_str.projdata)
    end
end
