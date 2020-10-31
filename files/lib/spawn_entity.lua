dofile_once("mods/azoth/files/lib/goki_variables.lua")

local self = GetUpdatedEntityID()
local x, y = EntityGetTransform(self)

local to_spawn = EntityGetVariableString(self, "to_spawn", nil)

if to_spawn ~= nil then
    EntityLoad(to_spawn, x, y)
end
