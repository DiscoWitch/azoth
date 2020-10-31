self = GetUpdatedEntityID()

local mic = EntityGetFirstComponent(self, "MaterialInventoryComponent")
local mats = ComponentGetValue2(mic, "count_per_material_type")

local elixir_id = CellFactory_GetType("murky_elixir") + 1
local elixir_amt = mats[elixir_id]

if elixir_amt > 500 then
    EntitySetComponentsWithTagEnabled(self, "enabled_by_elixir", true)
else
    EntitySetComponentsWithTagEnabled(self, "enabled_by_elixir", false)
end

