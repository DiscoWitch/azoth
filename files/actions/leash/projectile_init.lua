dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity.Current()

local shooter = Entity(self.ProjectileComponent.mWhoShot)
if not shooter then return end

local handle = shooter:children():search(function(ent) return ent:name() == "leash_handle" end)
if not handle then
    local x, y = shooter:transform()
    handle = Entity(EntityLoad("mods/azoth/files/actions/leash/leash_handle.xml", x, y))
    handle:setParent(shooter)
end
handle.var_bool.can_connect = true
