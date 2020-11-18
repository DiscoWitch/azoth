dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())

local parent = self:parent()
if not parent then
    return
end

if not self.var_bool.applied then
    self.var_bool.applied = true
    local effect = parent:addGameEffect("mods/azoth/files/status/target_polymorph/effect.xml")
    effect.GameEffectComponent.polymorph_target = "data/entities/animals/worm_big.xml"
    effect.GameEffectComponent.frames = 1800
    self.GameEffectComponent.frames = 5
end
