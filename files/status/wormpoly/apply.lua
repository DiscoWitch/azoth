dofile_once("mods/azoth/files/lib/disco_util.lua")
local polytools = dofile_once("mods/azoth/files/lib/polytools.lua")

local self = Entity(GetUpdatedEntityID())

local parent = self:parent()
if not parent then
    return
end

if not self.var_bool.applied then
    self.var_bool.applied = true
    self.GameEffectComponent.frames = 5
    polytools.polymorph(parent, "data/entities/animals/worm_big.xml", 1800, true, nil, true)
end
