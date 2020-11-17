dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local contents = self:children()
if contents then
    for k, v in contents:ipairs() do
        v:setEnabledWithTag("enabled_in_hand", false)
    end
    self.ItemComponent.uses_remaining = contents:len()
else
    self.ItemComponent.uses_remaining = 0
end

if self:root():id() ~= self:id() then
    local comp = Component(GetUpdatedComponentID(), self:id())
    local ewe = LoadGameEffectEntityTo(self:root():id(), "data/entities/misc/effect_edit_wands_everywhere.xml")
    ewe = Entity(ewe)
    ewe.GameEffectComponent.frames = comp.execute_every_n_frame
end
