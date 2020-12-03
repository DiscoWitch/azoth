dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
if self.var_bool.auto_stow then
    local storage = self:children():search(function(ent) return ent:name() == "spell_storage" end)
    local holder = self:root()
    local inventory = holder:children():search(function(ent)
        return ent:name() == "inventory_full"
    end)
    if inventory then
        local spells = inventory:children()
        if spells then
            for k, v in spells:ipairs() do v:setParent(storage) end
            holder.Inventory2Component.mForceRefresh = true
            self.var_bool.update_deck = true
            self.ItemComponent.uses_remaining = self.ItemComponent.uses_remaining + spells:len()
        end
    end
end
