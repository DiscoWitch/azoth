dofile_once("mods/azoth/files/lib/xml/xml.lua")

function getMaterials(biome)
    local mats = biome.Biome.Materials
    local output = {
        layer_stone = mats:getChildrenWithProp("MaterialComponent", "is_rare", "0"),
        ores = mats:getChildrenWithProp("MaterialComponent", "is_rare", "1"),
        vegetation = mats:getChildrenWithProp("VegetationComponent")
    }
    return output
end

function setMaterials(biome, materials)
    local bmats = biome.Biome.Materials
    biome.Biome:removeChildren({bmats})
    local new_mats = nodeFromDict("Materials", {
        name = bmats["@name"]
    })
    new_mats:addChildren(materials.ores)
    new_mats:addChildren(materials.layer_stone)
    new_mats:addChildren(materials.vegetation)
    biome.Biome:addChild(new_mats)
end
