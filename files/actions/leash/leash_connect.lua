dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
-- Create the leash between the knot and the shooter
local x, y = self:transform()

local max_length = 500
local handle = Entity.GetInRadius(x, y, max_length):search(
                   function(ent)
        return ent:id() ~= self:id() and ent:name() == "leash_handle" and ent.var_bool.can_connect
    end)

if not handle then
    -- Nothing to connect to
    self:kill()
    return
end

handle.var_bool.can_connect = false

local trail = Entity(EntityLoad("mods/azoth/files/actions/leash/leash.xml", x, y))
trail.var_int.knot = self:id()
trail.var_int.owner = handle:id()
