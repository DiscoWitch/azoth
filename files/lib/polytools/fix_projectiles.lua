dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
if self.ProjectileComponent then
    self.ProjectileComponent.on_death_explode = true
end
