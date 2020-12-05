dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

function DetachStorage()
    local self = Entity.Current()
    local item_storage = self:children():search(
                             function(ent) return ent:name() == "item_storage" end)
    if item_storage then
        self.var_int.item_storage = item_storage:id()
        item_storage:setParent(nil)
    end
    local spell_storage = self:children():search(function(ent)
        return ent:name() == "spell_storage"
    end)
    if spell_storage then
        self.var_int.spell_storage = spell_storage:id()
        spell_storage:setParent(nil)
    end
    return item_storage, spell_storage
end
function ReattachStorage()
    local self = Entity.Current()
    local item_storage = self:children():search(
                             function(ent) return ent:name() == "item_storage" end)
    if not item_storage then item_storage = Entity(self.var_int.item_storage) end
    if item_storage:parent() ~= self then item_storage:setParent(self) end
    local spell_storage = self:children():search(function(ent)
        return ent:name() == "spell_storage"
    end)
    if not spell_storage then spell_storage = Entity(self.var_int.spell_storage) end
    if spell_storage:parent() ~= self then spell_storage:setParent(self) end
    return item_storage, spell_storage
end
function GetWands(owner)
    local children = owner:children()
    local inv = children
                    and children:search(function(ent) return ent:name() == "inventory_quick" end)
    local items = inv and inv:children()
    local wands = items and items:search(function(ent)
        return ent.AbilityComponent and ent.AbilityComponent.use_gun_script
    end)
    return wands
end
function GetItems(owner)
    local children = owner:children()
    local inv = children
                    and children:search(function(ent) return ent:name() == "inventory_quick" end)
    local items = inv and inv:children()
    local wands = items and items:search(function(ent)
        return not (ent.AbilityComponent and ent.AbilityComponent.use_gun_script)
    end)
    return wands
end
function GetSpells(owner)
    local children = owner:children()
    local inv =
        children and children:search(function(ent) return ent:name() == "inventory_full" end)
    return inv and inv:children()
end
