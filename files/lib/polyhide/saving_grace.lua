dofile_once("mods/azoth/files/lib/disco_util.lua")

function damage_received(damage, message, entity_thats_responsible, is_fatal)
    local self = Entity(GetUpdatedEntityID())
    if is_fatal then
        self.DamageModelComponent.hp = damage + 1 / 25

        local effect = self:findChildren(function(ent)
            return ent:name() == "targeted_polymorph"
        end)
        effect.GameEffectComponent.frames = 1
        EntityRemoveComponent(self:id(), GetUpdatedComponentID())
    end
end
