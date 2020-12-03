dofile_once("data/scripts/lib/coroutines.lua");
dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
dofile_once("mods/azoth/files/items/containers/inventory_utils.lua")

function AddToBag(item, storage, holder, capacity)
    local stored_items = storage:children()
    if stored_items then
        local bag_slots = {}
        for i = 0, capacity - 1 do bag_slots[i] = true end
        for k, v in stored_items:ipairs() do bag_slots[v.var_int.bag_slot] = false end
        for i = 0, capacity - 1 do
            if bag_slots[i] then
                item.var_int.bag_slot = i
                break
            end
        end
    else
        item.var_int.bag_slot = 0
    end
    item:setParent(storage)
    holder.Inventory2Component.mForceRefresh = true
end

local selected_item = nil
local gui = GuiCreate()
async_loop(function()
    if not gui then
        if pause_effect then pause_effect.GameEffectComponent.frames = 0 end
        wait(0)
        return
    end
    local self = Entity.Current()
    local inventory = self:parent()
    local holder = inventory:parent()

    local pause_effect = holder:children():search(function(ent)
        return ent:name() == "azoth_pause"
    end)

    local invgui = holder.InventoryGuiComponent
    if not invgui or not invgui.mActive then
        if pause_effect then pause_effect.GameEffectComponent.frames = 0 end
        wait(0)
        return
    end
    local disable_controls = false

    GuiStartFrame(gui)

    local storage = self:children():search(function(ent) return ent:name() == "item_storage" end)
    local capacity = self.ItemComponent.max_child_items
    local current_size = self.ItemComponent.uses_remaining
    if capacity == -1 then
        -- Bottomless bag: Capacity is infinite
        local stored_items = storage:children()
        if stored_items then
            for k, v in stored_items:ipairs() do
                if v.var_int.bag_slot + 1 >= capacity then
                    capacity = v.var_int.bag_slot + 2
                end
            end
        else
            capacity = 1
        end
    end

    -- Get which inventory slots are free to put items in
    local wand_slots = {}
    local item_slots = {}
    for i = 1, 4 do
        wand_slots[i] = true
        item_slots[i] = true
    end

    -- Create stow icons
    if current_size < capacity then
        for k, item in inventory:children():ipairs() do
            local ic = item.ItemComponent
            local ac = item.AbilityComponent
            -- Get the current x position for the bag icon
            local slot = ic.inventory_slot
            local is_wand = ac and ac.use_gun_script
            -- Mark the item's slot as full
            if is_wand then
                wand_slots[slot.x + 1] = false
            else
                item_slots[slot.x + 1] = false
            end
            if item ~= self then
                -- Draw the bag icon
                local sprite = "mods/azoth/files/items/containers/bag_holding/icon.png"
                local x, y = GetQuickSlotPos(slot.x, is_wand)
                y = y + 21
                GuiZSetForNextWidget(gui, -0.1)
                GuiImageCentered(gui, 2000 + item:id(), x, y,
                                 "data/ui_gfx/inventory/inventory_box.png", 1, 1, 0)
                GuiZSetForNextWidget(gui, -0.2)
                local clicked, rclicked = GuiImageButtonCentered(gui, item:id(), x, y, "", sprite)
                if clicked then AddToBag(item, storage, holder, capacity) end
            end
        end
    end

    -- Draw the bag's background
    local x0 = 25
    local y0 = 80
    GuiImageNinePiece(gui, 10000, x0, y0, 20 * 5, 20 * 5, 1,
                      "mods/azoth/files/items/containers/background.png",
                      "mods/azoth/files/items/containers/background.png")

    GuiZSetForNextWidget(gui, -0.1)
    GuiBeginScrollContainer(gui, 1234, x0, y0, 20 * 5, 20 * 5, true, 0, 0)
    -- Draw the slots that the bag can hold
    for i = 1, capacity do
        local x = 20 * ((i - 1) % 5)
        local y = 20 * math.floor((i - 1) / 5)
        GuiZSetForNextWidget(gui, -0.1)
        GuiImage(gui, 10000 + i, x, y, "data/ui_gfx/inventory/quick_inventory_box.png", 1, 1, 0)
    end
    -- Draw the items in the bag
    local stored_items = storage:children()
    if stored_items then
        for _, item in stored_items:ipairs() do
            local ic = item.ItemComponent
            local ac = item.AbilityComponent
            local sprite = ac.sprite_file
            if sprite == "" then sprite = ic.ui_sprite end
            local slot = item.var_int.bag_slot

            local x = 10 + 20 * (slot % 5)
            local y = 10 + 20 * math.floor(slot / 5)
            if item == selected_item then
                GuiZSetForNextWidget(gui, -0.15)
                GuiImageCentered(gui, 9999, x, y,
                                 "data/ui_gfx/inventory/full_inventory_box_highlight.png", 1, 1, 0)
            end
            if item.MaterialInventoryComponent then
                local color = GetPotionColorNormalized(item)
                GuiColorSetForNextWidget(gui, color.r, color.g, color.b, color.a)
            end

            GuiZSetForNextWidget(gui, -1)
            local clicked, rclicked = GuiImageButtonCentered(gui, item:id(), x, y, "", sprite)
            GuiTooltip(gui, GetItemName(item), ic.ui_description)
            if clicked then
                if item == selected_item then selected_item = nil end
                local is_wand = ac and ac.use_gun_script
                local free_slots = is_wand and wand_slots or item_slots
                for i = 1, 4 do
                    if free_slots[i] then
                        ic.inventory_slot = {x = i - 1, y = 0}
                        item:setParent(inventory)
                        holder.Inventory2Component.mForceRefresh = true
                        break
                    end
                end
            end
            if rclicked then
                if item == selected_item then
                    selected_item = nil
                elseif not selected_item then
                    selected_item = item
                else
                    local temp = item.var_int.bag_slot
                    item.var_int.bag_slot = selected_item.var_int.bag_slot
                    selected_item.var_int.bag_slot = temp
                    selected_item = nil
                end
            end
        end
        self.ItemComponent.uses_remaining = stored_items:len()
    else
        self.ItemComponent.uses_remaining = 0
    end
    GuiEndScrollContainer(gui)

    if disable_controls then
        if not pause_effect then
            holder:addGameEffect("mods/azoth/files/status/pause/effect.xml")
        end
    elseif pause_effect then
        pause_effect.GameEffectComponent.frames = 0
    end
    wait(0)
end)
