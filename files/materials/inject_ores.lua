function InjectOre(biomefile, orefile)
    local pattern = "(<[%s]-Materials[%s]-name=\"[^\"]*\"[%s]->)"
    local biome = ModTextFileGetContent(biomefile)
    local ore = ModTextFileGetContent(orefile)
    biome = string.gsub(biome, pattern, "%1\n" .. ore)
    ModTextFileSetContent(biomefile, biome)
end

InjectOre("data/biome/excavationsite.xml", "mods/azoth/files/materials/ores_excavationsite.xml")
InjectOre("data/biome/snowcave.xml", "mods/azoth/files/materials/ores_snowcave.xml")

