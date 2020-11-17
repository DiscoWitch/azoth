dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local storage = self:findChildren(function(ent)
    return ent:name() == "storage"
end)[1]
local inventory = self:parent()
local holder = inventory:parent()
if holder then
    local now = GameGetFrameNum();
    local controls = holder.ControlsComponent
    if controls then
        local main_fire = controls.mButtonDownFire and (now - controls.mButtonFrameFire) % 30 == 0
        local alt_fire = controls.mButtonDownThrow and controls.mButtonFrameThrow == now
        if main_fire or alt_fire then
            -- Find the item directly after the bag if it exists and stow it
            local ic = self.ItemComponent
            local islot = ic.inventory_slot
            local item = inventory:findChildren(function(ent)
                local is_wand = ent.AbilityComponent.use_gun_script
                return ent.ItemComponent.inventory_slot.x == (islot.x + 1) % 4 and not is_wand
            end)
            if item then
                item:setParent(storage)
                ic.uses_remaining = ic.uses_remaining + 1
            end
        end
        if main_fire then
            -- Pull an item out of storage into the now-empty slot
            local ic = self.ItemComponent
            local islot = ic.inventory_slot
            local stored = storage:childrenUnwrapped()
            if stored then
                local slot = (self.var_int.inv_slot or 0) % #stored + 1
                self.var_int.inv_slot = slot
                local item = Entity(stored[slot])
                -- Make sure the item appears in the same slot the bag would stow from
                item.ItemComponent.inventory_slot = {
                    x = (islot.x + 1) % 4,
                    y = islot.y
                }
                item:setParent(inventory)
                ic.uses_remaining = ic.uses_remaining - 1
            end
        end

    end
end
