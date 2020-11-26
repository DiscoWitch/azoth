dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity.Current()

print("checking for upgrades")

local mats = self.MaterialInventoryComponent.count_per_material_type
local ichor_id = CellFactory_GetType("magic_liquid_ichor")
print(tostring(mats[ichor_id - 1]))
