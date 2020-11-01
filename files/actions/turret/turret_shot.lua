dofile_once("mods/azoth/files/lib/goki_variables.lua")

function wand_fired(my_wand)
    local self = GetUpdatedEntityID()
    EntitySetVariableNumber(my_wand, "owner", self)

    -- Look through all of my actions and synchronize their remaining uses
    -- with the originals
    for k, v in ipairs(EntityGetAllChildren(my_wand)) do
        if EntityHasTag(v, "card_action") then
            local original = EntityGetVariableNumber(v, "original", 0)
            if EntityGetIsAlive(original) then
                local my_ic = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
                local my_uses = ComponentGetValue2(my_ic, "uses_remaining")
                local ic = EntityGetFirstComponentIncludingDisabled(original, "ItemComponent")
                local orig_uses = ComponentGetValue2(ic, "uses_remaining")
                local new_uses = math.min(my_uses, orig_uses)
                ComponentSetValue2(my_ic, "uses_remaining", new_uses)
                ComponentSetValue2(ic, "uses_remaining", new_uses)
            end
        end
    end
end
