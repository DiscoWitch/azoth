dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())

if self:root():id() ~= self:id() then
    local comp = Component(GetUpdatedComponentID(), self:id())
    local ewe = LoadGameEffectEntityTo(self:root():id(), "data/entities/misc/effect_edit_wands_everywhere.xml")
    ewe = Entity(ewe)
    ewe.GameEffectComponent.frames = comp.execute_every_n_frame
end
