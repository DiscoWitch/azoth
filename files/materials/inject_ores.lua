dofile_once("mods/azoth/files/lib/xml/biome.lua")

local parser = newParser()

function injectCobalt(filename)
    local cobalt = nodeFromDict("MaterialComponent", {
        _enabled = "1",
        is_rare = "1",
        limit_max_y = "2048",
        limit_min_y = "100",
        limit_y = "0",
        material_index = "10",
        material_max = "1.0",
        material_min = "0.5",
        material_name = "cobalt",
        rare_polka_is_boxed = "1",
        rare_polka_probability = "0.2",
        rare_polka_radius_high = "0.65",
        rare_polka_radius_low = "0.2",
        rare_required_max = "10",
        rare_required_min = "0.2",
        rare_scale_x = "0.05",
        rare_scale_y = "0.05",
        rare_use_perlin = "0",
        rare_use_polka = "1"
    })

    local parsedXml = parser:ParseXmlText(ModTextFileGetContent(filename))
    local mats = getMaterials(parsedXml)
    table.insert(mats.ores, cobalt)
    setMaterials(parsedXml, mats)

    ModTextFileSetContent(filename, parsedXml.Biome:toString())
end

injectCobalt("data/biome/snowcave.xml")

