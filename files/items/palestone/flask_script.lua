dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()

local mats = self.MaterialInventoryComponent.count_per_material_type
local elixir_id = CellFactory_GetType("azoth_caput_mortuum") + 1
local elixir_amt = mats[elixir_id]

if elixir_amt > 500 then
    self:setEnabledWithTag("enabled_by_elixir", true)
else
    self:setEnabledWithTag("enabled_by_elixir", false)
end

