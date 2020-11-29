dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

function throw_item(from_x, from_y, to_x, to_y)
    print("throw script!")
    local self = Entity.Current()
    local ac = self.AbilityComponent
    if ac and self.var_int.deck_capacity then
        ac.gun_config.deck_capacity = self.var_int.deck_capacity
    end
end
