dofile_once("mods/azoth/files/lib/xml/xml.lua")

local parser = newParser()

local electricity_entities = {"data/entities/misc/electricity.xml", "data/entities/misc/arc_electric.xml"}

local cobalt_transmute = nodeFromDict("MagicConvertMaterialComponent", {
    _enabled = "1",
    radius = "2",
    is_circle = "1",
    from_material = "cobalt",
    to_material = "cobalt_lodestone",
    loop = "0"
})

for k, v in ipairs(electricity_entities) do
    local parsedXml = parser:ParseXmlText(ModTextFileGetContent(v))
    parsedXml.Entity:addChild(cobalt_transmute)
    ModTextFileSetContent(v, parsedXml.Entity:toString())
end
