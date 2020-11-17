function spawn_corpse(x, y)
    EntityLoad("data/entities/props/physics_skull_01.xml", x, y - 4)
    EntityLoad("data/entities/props/physics_bone_01.xml", x + 8, y - 4)
    EntityLoad("data/entities/props/physics_bone_06.xml", x - 12, y - 4)
    EntityLoad("data/entities/items/books/book_corpse.xml", x, y)
    EntityLoad("mods/azoth/files/items/bag_holding2/bag.xml", x, y - 10)
end
