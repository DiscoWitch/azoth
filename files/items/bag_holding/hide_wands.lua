dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

function enabled_changed(entity_id, is_enabled)
    local self = Entity.Current()
    local inventory = self:parent()
    local items = inventory:children()
    if is_enabled then
        for k, item in items:ipairs() do
            local ac = item.AbilityComponent
            if ac and ac.gun_config.deck_capacity > 0 then
                item.var_int.deck_capacity = ac.gun_config.deck_capacity
                ac.gun_config.deck_capacity = 0
            end
        end
    else
        for k, item in items:ipairs() do
            local ac = item.AbilityComponent
            if ac and item.var_int.deck_capacity then
                ac.gun_config.deck_capacity = item.var_int.deck_capacity
            end
        end
    end
end
