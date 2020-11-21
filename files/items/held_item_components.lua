dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity.Current()
local inventory = self:children():search(function(ent) return ent:name() == "inventory_quick" end)
local items = inventory:children()
if items then
    for k, v in items:ipairs() do
        if not v.var_bool.azoth_components_added then
            local i = v.ItemComponent
            if i and i.item_name == "$item_potion" then
                v:loadComponents("mods/azoth/files/items/flasks/flask_components.xml", true)
                v.var_bool.azoth_components_added = true
            end
        end
    end
end
