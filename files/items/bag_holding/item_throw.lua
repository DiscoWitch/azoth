dofile_once("mods/azoth/files/lib/disco_util.lua")

function throw_item(from_x, from_y, to_x, to_y)
    print("throw item!")
    local self = Entity.Current()
    self.ItemComponent.preferred_inventory = "QUICK"
end
