dofile_once("data/scripts/lib/coroutines.lua");
dofile_once("data/scripts/lib/utilities.lua");
dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local gui = GuiCreate()

function GetPotionColorNormalized(item)
    local c = GameGetPotionColorUint(item:id())
    local color = {
        r = bit.band(bit.rshift(c, 0), 0xff) / 0xff,
        g = bit.band(bit.rshift(c, 8), 0xff) / 0xff,
        b = bit.band(bit.rshift(c, 16), 0xff) / 0xff,
        a = bit.band(bit.rshift(c, 24), 0xff) / 0xff
    }
    return color
end

function GetMaterialName(id_name)
    local trans_string = "$mat_" .. id_name
    local name = GameTextGetTranslatedOrNot(trans_string)
    if name == "" then name = string.gsub(id_name, "_", " ") end
    return name
end

function GetItemName(item)
    local ac = item.AbilityComponent
    if item.MaterialInventoryComponent then
        local name = GameTextGetTranslatedOrNot(ac.ui_name)
        local most_material = 0
        local most_amount = 0
        for mat_id, amount in ipairs(item.MaterialInventoryComponent.count_per_material_type) do
            if amount > most_amount then
                most_amount = amount
                most_material = mat_id - 1
            end
        end
        if most_material == 0 then
            name = string.gsub(name, "$0", GameTextGetTranslatedOrNot("$item_empty"))
        else
            name = string.gsub(name, "$0", GetMaterialName(CellFactory_GetName(most_material)))
        end
        return GameTextGetTranslatedOrNot(name)
    else
        return GameTextGetTranslatedOrNot(ac.ui_name)
    end
end

function SortItems(a, b)
    local ascore = 0
    local bscore = 0
    if not a.AbilityComponent.use_gun_script then ascore = ascore + 4 end
    if not b.AbilityComponent.use_gun_script then bscore = bscore + 4 end
    if not a.MaterialInventoryComponent then ascore = ascore + 2 end
    if not b.MaterialInventoryComponent then bscore = bscore + 2 end
    if not a.BookComponent then ascore = ascore + 1 end
    if not b.BookComponent then bscore = bscore + 1 end
    if ascore ~= bscore then
        return ascore < bscore
    else
        return GetItemName(a):upper() < GetItemName(b):upper()
    end
end

local selected_item = nil

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

    local storage = self:children():search(function(ent) return ent:name() == "storage" end)
    local capacity = self.ItemComponent.max_child_items
    local current_size = self.ItemComponent.uses_remaining
    if capacity == -1 then
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

    local free_slots = {}
    for i = 1, 8 do free_slots[i] = true end
    local x0 = 22
    local y0 = 45
    -- Create stow icons
    if current_size < capacity then
        for k, item in inventory:children():ipairs() do
            if item == self then
                -- Don't allow putting a bg in itself
            else
                local ic = item.ItemComponent
                local ac = item.AbilityComponent

                -- Disable any wands while using the bag gui
                if ac and ac.gun_config.deck_capacity > 0 then
                    item.var_int.deck_capacity = ac.gun_config.deck_capacity
                    ac.gun_config.deck_capacity = 0
                end
                -- Get the current x position for the bag icon
                local slot = ic.inventory_slot
                local is_wand = ac and ac.use_gun_script
                free_slots[slot.x + (is_wand and 0 or 4) + 1] = false
                if not is_wand then slot.x = slot.x + 4 end
                -- Draw the bag icon
                local sprite = "mods/azoth/files/items/bag_holding/bag_ui.png"
                local width, height = GuiGetImageDimensions(gui, sprite, 1)
                local x = x0 + 20 * slot.x
                local y = y0 + 20 * slot.y
                GuiZSetForNextWidget(gui, -0.1)
                GuiImage(gui, 2000 + item:id(), x, y, "data/ui_gfx/inventory/inventory_box.png", 1,
                         1, 0)
                GuiZSetForNextWidget(gui, -0.2)
                local clicked, rclicked = GuiImageButton(gui, item:id(), x + (16 - width) / 2,
                                                         y + (16 - height) / 2, "", sprite)
                if clicked then
                    local stored_items = storage:children()
                    if stored_items then
                        local bag_slots = {}
                        for i = 0, capacity - 1 do bag_slots[i] = true end
                        for k, v in stored_items:ipairs() do
                            bag_slots[v.var_int.bag_slot] = false
                        end
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
            end
        end
    end

    x0 = 25
    y0 = 80
    GuiImageNinePiece(gui, 10000, x0, y0, 20 * 5, 20 * 5, 1,
                      "mods/azoth/files/items/bag_holding/background.png",
                      "mods/azoth/files/items/bag_holding/background.png")

    GuiZSetForNextWidget(gui, -0.1)
    GuiBeginScrollContainer(gui, 1234, x0, y0, 20 * 5, 20 * 5, true, 0, 0)

    for i = 1, capacity do
        local x = 20 * ((i - 1) % 5)
        local y = 20 * math.floor((i - 1) / 5)
        GuiZSetForNextWidget(gui, -0.1)
        GuiImage(gui, 10000 + i, x, y, "data/ui_gfx/inventory/quick_inventory_box.png", 1, 1, 0)
    end
    local stored_items = storage:children()
    if stored_items then
        for _, item in stored_items:ipairs() do
            local ic = item.ItemComponent
            local ac = item.AbilityComponent
            local sprite = ac.sprite_file
            if sprite == "" then sprite = ic.ui_sprite end
            local width, height = GuiGetImageDimensions(gui, sprite, 1)
            local slot = item.var_int.bag_slot

            local x = 20 * (slot % 5)
            local y = 20 * math.floor(slot / 5)
            if item == selected_item then
                GuiZSetForNextWidget(gui, -0.15)
                GuiImage(gui, 9999, x, y, "data/ui_gfx/inventory/full_inventory_box_highlight.png",
                         1, 1, 0)
            end
            x = x + (20 - width) / 2
            y = y + (20 - height) / 2
            if item.MaterialInventoryComponent then
                local color = GetPotionColorNormalized(item)
                GuiColorSetForNextWidget(gui, color.r, color.g, color.b, color.a)
            end

            GuiZSetForNextWidget(gui, -1)
            local clicked, rclicked = GuiImageButton(gui, item:id(), x, y, "", sprite)
            GuiTooltip(gui, GetItemName(item), ic.ui_description)
            if clicked then
                if item == selected_item then selected_item = nil end
                local is_wand = ac and ac.use_gun_script
                for i = 1, 4 do
                    local new_slot = i + ((is_wand and 0) or 4)
                    if free_slots[new_slot] then
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
