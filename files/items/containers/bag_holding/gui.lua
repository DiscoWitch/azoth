dofile_once("data/scripts/lib/coroutines.lua");
dofile_once("mods/azoth/files/items/containers/inventory_utils.lua")
dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
---@type GUI
local dgui = dofile_once("mods/azoth/files/lib/disco_util/disco_gui.lua")
GUIInitInventory()

local bag_item = Entity.Current()
local holder = bag_item:root()
local inventory = holder:children():search(function(ent) return ent:name() == "inventory_quick" end)

local storage, _ = ReattachStorage()

local capacity = bag_item.ItemComponent.max_child_items

local inventory_items = {}
local stored_items = {}
local box_width = 8

local gui = dgui.Create()
local draggable = gui:DragContainer(100, 100)
draggable.free_drag = true
draggable:Image(-10, -10, "mods/azoth/files/items/containers/bag_holding/icon.png")
local deck_box = draggable:AutoBox(0, 0, "mods/azoth/files/items/containers/background.png")
deck_box.z = 0
deck_box.margins = {-5, -5, -5, -5}

-- The vertical sections for spell groups
local bag = {root = deck_box:GridBox(0, 0, true)}
bag.root.separation_y = 5

-- Slots containing the player's inventory items
bag.inventory = bag.root:GUIContainer(0, 0)
bag.invgrid = bag.inventory:GridBoxInstanced(2, 2, 8, false, 20 * box_width)
local invslot = bag.invgrid:InventorySlot(0, 0)
invslot.inventory = inventory

function invslot:init()
    local i = self.instance_index
    self.disable_drag = (inventory_items[i] == bag_item)
    self.darken_slot = (inventory_items[i] == bag_item)
    self.slot = {x = i - 1, y = 0}
    if self.slot.x > 3 then self.slot.x = self.slot.x - 4 end
    self:setItem(inventory_items[i])
end
function invslot:putItem(item, dry_run)
    if not item then
        print_error("Invalid drag item")
        return
    end
    if self.inventory then
        if dry_run then return self.item end
        -- Put it in the linked inventory
        async(function()
            item:setParent(nil)
            wait(0)
            item.ItemComponent.inventory_slot = self.slot or {x = 0, y = 0}
            item:setParent(self.inventory)
            if self.update_inventory then self:update_inventory() end
        end)
        return self.item
    end
end
function invslot:item_filter(src_slot, swapping)
    -- Don't allow swapping the bag
    if self.item == bag_item then return false end
    local i = self.instance_index
    local item = src_slot.item
    if i <= 4 then
        -- Accept wands
        return item.AbilityComponent.use_gun_script
    else
        -- Accept non-wands
        return not item.AbilityComponent.use_gun_script
    end
end

-- The items in the bag
bag.contents = bag.root:ScrollContainer(0, 0, {-10, 20 * box_width - 10, -10, 20 * box_width - 10})
bag.contents.id = 1
bag.contents.cull_margin = {x = -10, y = -10}

bag.item_grid = bag.contents:GridBoxInstanced(0, 0, 1, false, 20 * box_width)
local item = bag.item_grid:InventorySlot(0, 0)
function item:init()
    local i = self.instance_index
    self.inventory = storage
    self.slot = {x = i - 1, y = 0}
    self:setItem(stored_items[i])
end
function item:update()
    local i = self.instance_index
    if self.item ~= stored_items[i] then self:setItem(stored_items[i]) end
end
function item:update_inventory() UpdateStorage() end

function UpdateStorage()
    storage, _ = ReattachStorage()
    capacity = bag_item.ItemComponent.max_child_items
    local items = storage:children()
    stored_items = {}
    local max_slot = 0
    if items then
        for _, i in items:ipairs() do
            local slot = i.ItemComponent.inventory_slot
            stored_items[slot.x + 1] = i
            if slot.x >= max_slot then max_slot = slot.x + 1 end
        end
        bag_item.ItemComponent.uses_remaining = items:len()
    else
        bag_item.ItemComponent.uses_remaining = 0
    end
    if capacity == -1 then
        -- Bottomless bag: Capacity is infinite
        capacity = max_slot + 1
    end
    bag.item_grid.count = capacity
    bag.item_grid.update_children = true
end

UpdateStorage()

async_loop(function()
    if not gui.handle then
        wait(0)
        return
    end
    bag_item = Entity.Current()
    holder = bag_item:root()
    gui.player = holder
    local invgui = holder.InventoryGuiComponent
    if not invgui or not invgui.mActive then
        wait(0)
        return
    end
    inventory = holder:children():search(function(ent) return ent:name() == "inventory_quick" end)
    local old_items = inventory_items
    inventory_items = {}
    local inv_items = inventory:children()
    if inv_items then
        for _, itm in inv_items:ipairs() do
            local slot = itm.ItemComponent.inventory_slot
            -- non-wand items go in the back four slots
            if not itm.AbilityComponent.use_gun_script then slot.x = slot.x + 4 end
            inventory_items[slot.x + 1] = itm
        end
    end
    for i = 1, 8 do
        -- Update the bag if an inventory slot changed
        if inventory_items[i] ~= old_items[i] then
            bag.invgrid.update_children = true
            break
        end
    end
    if bag_item.var_bool.update_storage then
        UpdateStorage()
        bag_item.var_bool.update_storage = false
    end
    gui:render()
    wait(0)
end)
