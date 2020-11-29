local _spawn_corpse = spawn_corpse
function spawn_corpse(x, y)
    _spawn_corpse(x, y)
    EntityLoad("mods/azoth/files/items/bag_holding/bag.xml", x, y - 10)
end
