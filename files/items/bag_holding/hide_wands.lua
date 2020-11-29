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

                local has_script = false
                local script = "mods/azoth/files/items/bag_holding/throw_wand.lua"
                if item.LuaComponent then
                    for _, v in item.LuaComponent:ipairs() do
                        if v.script_throw_item == script then
                            print("found throw script")
                            has_script = true
                            break
                        end
                    end
                end
                if not has_script then
                    item:addComponent("LuaComponent", {
                        _tags = "enabled_in_inventory,enabled_in_hand,enabled_in_world",
                        script_throw_item = script,
                        remove_after_executed = true,
                        execute_every_n_frame = -1
                    })
                end
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
