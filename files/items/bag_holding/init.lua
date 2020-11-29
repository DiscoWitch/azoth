dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
local self = Entity.Current()
local start_size = tonumber(ModSettingGet("azoth.bag_holding.size"))
print(tostring(start_size))
self.ItemComponent.max_child_items = start_size
if ModSettingGet("azoth.bag_holding.bottomless") then self.ItemComponent.max_child_items = -1 end
