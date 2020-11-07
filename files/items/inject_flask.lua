function AddComponent(entity_file, component)
    local ent = ModTextFileGetContent(entity_file)
    local comp = ModTextFileGetContent(component)
    ent = string.gsub(ent, "(</Entity>)", comp .. "\n%1\n")
    ModTextFileSetContent(entity_file, ent)
end

function AddTag(entity_file, tag)
    local pattern = "(<[%s]-Entity[^>]-tags=\"[^\"]*)(\"[^>]->)"
    local ent = ModTextFileGetContent(entity_file)
    ent = string.gsub(ent, pattern, "%1," .. tag .. "%2")
    ModTextFileSetContent(entity_file, ent)
end

local potions = {"data/entities/items/pickup/potion.xml", "data/entities/items/pickup/potion_water.xml",
                 "data/entities/items/pickup/potion_alcohol.xml", "data/entities/items/pickup/potion_aggressive.xml"}
for k, v in ipairs(potions) do
    AddComponent(v, "mods/azoth/files/items/inject_flask.xml")
    AddTag(v, "forgeable")
end
