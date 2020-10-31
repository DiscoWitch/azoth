dofile_once("mods/azoth/files/lib/xml/entity.lua")

local parser = newParser()

local potions = {"data/entities/items/pickup/potion.xml", "data/entities/items/pickup/potion_water.xml",
                 "data/entities/items/pickup/potion_alcohol.xml", "data/entities/items/pickup/potion_aggressive.xml"}

local components = ModTextFileGetContent("mods/azoth/files/items/palestone/flask_inject.xml")

for k, v in ipairs(potions) do
    print("adding script to flasks")
    addXMLComponent(v, components)
end
