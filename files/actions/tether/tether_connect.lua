dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local x, y = self:transform()
local max_length = 500
local other = Entity.GetInRadius(x, y, max_length):search(
                  function(ent)
        return ent:id() ~= self:id() and ent:name() == "tether_knot" and ent.var_bool.can_connect
    end)

if not other then
    -- Nothing to connect to
    self.var_bool.can_connect = true
    return
end

self.var_bool.can_connect = false
other.var_bool.can_connect = false
-- Turn off the particles that indicate an unconnected knot
self.ParticleEmitterComponent:setEnabled(false)
other.ParticleEmitterComponent:setEnabled(false)

-- Create the tether between the two knots
local trail = Entity(EntityLoad("mods/azoth/files/actions/tether/tether.xml", x, y))
trail.var_int.knot1 = self:id()
trail.var_int.knot2 = other:id()
