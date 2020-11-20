dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())

local children = self:children()
local contents = children and children:search(function(ent)
    return ent.ItemComponent ~= nil
end)
if contents then
    self.ItemComponent.uses_remaining = contents:len()
else
    self.ItemComponent.uses_remaining = 0
end

local comp = Component(GetUpdatedComponentID(), self:id())
local window = GameGetFrameNum() - comp.execute_every_n_frame
local activated = self.MaterialInventoryComponent.last_frame_drank > window
local full = self.ItemComponent.uses_remaining >= self.AbilityComponent.gun_config.deck_capacity
if activated and not full then
    local holder = self:root()
    local inventory = holder:children():search(function(ent)
        return ent:name() == "inventory_quick"
    end)
    local item = Entity(holder.Inventory2Component.mActiveItem)
    item:setParent(self)
    item:setEnabledWithTag("enabled_in_hand", false)
    holder.Inventory2Component.mActiveItem = inventory:children():id()
    holder.Inventory2Component.mActualActiveItem = 0
    holder.Inventory2Component.mForceRefresh = true
end
AddMaterialInventoryMaterial(self:id(), "azoth_bag", 1)
