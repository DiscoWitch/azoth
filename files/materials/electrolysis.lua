local self = GetUpdatedEntityID()

EntityAddComponent2(self, "MagicConvertMaterialComponent", {
    radius = 2,
    is_circle = true,
    from_material = CellFactory_GetType("cobalt"),
    to_material = CellFactory_GetType("cobalt_lodestone"),
    loop = false
})
