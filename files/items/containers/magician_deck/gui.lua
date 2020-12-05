dofile_once("data/scripts/lib/coroutines.lua");
dofile_once("mods/azoth/files/items/containers/inventory_utils.lua")
dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
---@type GUI
local dgui = dofile_once("mods/azoth/files/lib/disco_util/disco_gui.lua")
GUIInitInventory()

local deck_item = Entity.Current()
local holder = deck_item:root()
local inventory = holder:children():search(function(ent) return ent:name() == "inventory_full" end)
local _, storage = ReattachStorage()
local capacity = deck_item.ItemComponent.max_child_items
local current_size = deck_item.ItemComponent.uses_remaining

local spellbar = {}
local stored_spells = nil
local wands = {}
local selected_wand = nil
local cur_wand_spells = {}
local box_width = 8

local gui = dgui.Create()

-- The whole deck window draws inside this
local draggable = gui:DragContainer(100, 100)
draggable.free_drag = true
draggable:Image(-10, -10, "data/ui_gfx/gun_actions/burst_4.png")
local deck_box = draggable:AutoBox(0, 0, "mods/azoth/files/items/containers/background.png")
deck_box.z = 0
deck_box.margins = {-5, -5, -5, -5}

-- The vertical sections for spell groups
local deck = {root = deck_box:GridBox(0, 0, true)}
deck.root.separation_y = 5

deck.settings = deck.root:GridBox(2, 2)
local stow_all = deck.settings:GUIContainer(0, 0)
stow_all:Image(0, 0, "data/ui_gfx/inventory/quick_inventory_box.png").z = 0
local stow_btn =
    stow_all:ImageButton(0, 0, "mods/azoth/files/items/containers/bag_holding/icon.png")
function stow_btn:on_click()
    if selected_wand then
        local spells = selected_wand:children()
        if spells then for _, v in spells:ipairs() do v:setParent(storage) end end
        UpdateWands()
    else
        for i = 1, 16 do if spellbar[i] then spellbar[i]:setParent(storage) end end
        spellbar = {}
    end
    UpdateStorage()
end
local ttbox = stow_btn:Tooltip(20, 0):AutoBox(0, 0)
ttbox.margins = {5, 5, 5, 5}
local ttgrid = ttbox:GridBox(0, 0, true)
ttgrid:Text(0, 0, "Put all spells into the deck")

local auto_stow = deck.settings:GUIContainer(0, 0)
auto_stow:Image(0, 0, "data/ui_gfx/inventory/quick_inventory_box.png").z = 0
local auto_stow_btn = auto_stow:ImageButton(0, 0,
                                            "mods/azoth/files/items/containers/bag_holding/icon.png")
ttbox = auto_stow_btn:Tooltip(20, 0):AutoBox(0, 0)
ttbox.margins = {5, 5, 5, 5}
ttgrid = ttbox:GridBox(0, 0, true)
local autostowtext = ttgrid:Text(0, 0, "")
if deck_item.var_bool.auto_stow then
    autostowtext.text = "stop automatically storing picked up spells"
else
    autostowtext.text = "automatically store picked up spells"
end
function auto_stow_btn:on_click()
    if deck_item.var_bool.auto_stow then
        autostowtext.text = "automatically store picked up spells"
        deck_item.var_bool.auto_stow = false
    else
        autostowtext.text = "stop automatically storing picked up spells"
        deck_item.var_bool.auto_stow = true
    end
end

-- The wand bar
deck.wand_bar = deck.root:GUIContainer(0, 0)
-- Only enable selecting wands with the upgraded deck
function deck.wand_bar:update() self.enabled = deck_item.var_bool.edit_wands end
deck.wand_bar_slots = deck.wand_bar:GridBoxInstanced(0, 0, 5, false, 20 * 5)
deck.wand_bar_slots:Image(0, 0, "data/ui_gfx/inventory/quick_inventory_box.png")
deck.wand_highlight = deck.wand_bar:Image(0, 0,
                                          "data/ui_gfx/inventory/full_inventory_box_highlight.png")
deck.wand_highlight.z = -0.3
deck.wand_highlight.update = function(self)
    -- Check that the selected wand is still in the inventory
    local found_wand = false
    for k, v in pairs(wands) do
        if v and v == selected_wand then
            found_wand = true
            self.x = 20 * k
        end
    end
    if not found_wand then
        self.x = 0
        selected_wand = nil
    end
end
-- Buttons to select wands
deck.no_wand = deck.wand_bar:ImageButton(0, 0, "data/ui_gfx/gun_actions/nolla.png")
deck.no_wand.z = -0.4
deck.no_wand.on_click = function(self) selected_wand = nil end
deck.wand_buttons = {}
for i = 1, 4 do
    deck.wand_buttons[i] = deck.wand_bar:ImageButton(20 * i, 0, "data/ui_gfx/gun_actions/nolla.png")
    deck.wand_buttons[i].z = -0.5
    deck.wand_buttons[i].on_click = function(self)
        selected_wand = wands[i]
        UpdateWands()
    end
    deck.wand_buttons[i].update = function(self)
        if wands[i] then
            self.enabled = true
            self.sprite = wands[i].AbilityComponent.sprite_file
        else
            self.enabled = false
        end
    end
end

-- Slots containing the spellbar/wand's spells
deck.wand_info = deck.root:GUIContainer(0, 0)
deck.wand_grid = deck.wand_info:GridBoxInstanced(2, 2, 1, false, 20 * box_width)
local wslot = deck.wand_grid:InventorySlot(0, 0)
function deck.wand_grid:update()
    if selected_wand then
        wslot.inventory = selected_wand
        self.count = selected_wand.var_int.deck_capacity
                         or selected_wand.AbilityComponent.gun_config.deck_capacity
    else
        wslot.inventory = inventory
        self.count = 16
    end
end
function wslot:putItem(item, dry_run)
    if not item then
        print_error("Invalid drag item")
        return
    end
    if self.inventory then
        if dry_run then return self.item end
        -- Remove it from the inventory for one frame to make the slot change stick
        async(function()
            item:setParent(nil)
            wait(0)
            item.ItemComponent.inventory_slot = self.slot or {x = 0, y = 0}
            item:setParent(self.inventory)
        end)
        local return_item = self.item
        self:update_inventory()
        self:setItem(item)
        return return_item
    end
end
function wslot:init()
    local i = self.instance_index
    self.slot = {x = i - 1, y = 0}
    if selected_wand then
        self:setItem(cur_wand_spells[i])
    else
        self:setItem(spellbar[i])
    end
end
function wslot:update()
    local i = self.instance_index
    local item = nil
    if selected_wand then
        item = cur_wand_spells[i]
    else
        item = spellbar[i]
    end
    if item ~= self.item then self:setItem(item) end
end
function wslot:on_click()
    local item = self.item
    if not item then return end
    item:setParent(storage)
    if selected_wand then
        cur_wand_spells[self.instance_index] = nil
    else
        spellbar[self.instance_index] = nil
    end
    UpdateStorage()
end
function wslot:on_right_click()
    if not selected_wand then return end
    local item = self.item
    if not item then return end
    for i = 1, 16 do
        if not spellbar[i] then
            item.ItemComponent.inventory_slot = {x = i - 1, y = 0}
            item:setParent(inventory)
            cur_wand_spells[self.instance_index] = nil
            break
        end
    end
end
function wslot:update_inventory()
    if selected_wand then
        cur_wand_spells[self.instance_index] = self.item
    else
        spellbar[self.instance_index] = self.item
    end
end

-- The spells in the deck
deck.spells = deck.root:ScrollContainer(0, 0, {-10, 20 * box_width - 10, -10, 20 * box_width - 10})
deck.spells.id = 1
deck.spells.cull_margin = {x = -10, y = -10}

deck.spell_grid = deck.spells:GridBoxInstanced(0, 0, 1, false, 20 * box_width)
local deck_slot = deck.spell_grid:InventorySlot(0, 0)
function deck_slot:init()
    local i = self.instance_index
    self.inventory = storage
    if stored_spells then self:setItem(stored_spells[i]) end
end
function deck_slot:update_inventory() UpdateStorage() end
function deck_slot:on_click()
    if selected_wand then
        local slots = selected_wand.var_int.deck_capacity
                          or selected_wand.AbilityComponent.gun_config.deck_capacity
        for i = 1, slots do
            if not cur_wand_spells[i] then
                local item = self.item
                item.ItemComponent.inventory_slot = {x = i - 1, y = 0}
                item:setParent(selected_wand)
                if selected_wand then
                    cur_wand_spells[i] = item
                else
                    spellbar[i] = item
                end
                UpdateStorage()
                break
            end
        end
    else
        for i = 1, 16 do
            if not spellbar[i] then
                local item = self.item
                item.ItemComponent.inventory_slot = {x = i - 1, y = 0}
                item:setParent(inventory)
                UpdateStorage()
                break
            end
        end
    end
end
function deck_slot:on_right_click()
    for i = 1, 16 do
        if not spellbar[i] then
            local item = self.item
            item.ItemComponent.inventory_slot = {x = i - 1, y = 0}
            item:setParent(inventory)
            UpdateStorage()
            break
        end
    end
end
function deck_slot:putItem(item, dry_run)
    if not item then
        print_error("Invalid drag item")
        return
    end
    if dry_run then return nil end
    -- Put it in the linked inventory
    item:setParent(nil)
    item.ItemComponent.inventory_slot = self.slot or {x = 0, y = 0}
    item:setParent(self.inventory)
    if self.update_inventory then self:update_inventory() end
    return nil
end

function UpdateStorage()
    _, storage = ReattachStorage()
    capacity = deck_item.ItemComponent.max_child_items
    stored_spells = storage:children()
    if stored_spells then
        stored_spells:sort(SortSpells)
        deck_item.ItemComponent.uses_remaining = stored_spells:len()
    else
        deck_item.ItemComponent.uses_remaining = 0
    end
    current_size = deck_item.ItemComponent.uses_remaining
    if capacity == -1 then
        -- Bottomless deck: Capacity is infinite
        capacity = current_size + 1
    end
    deck.spell_grid.count = capacity
    deck.spell_grid.update_children = true
end

function UpdateWands()
    cur_wand_spells = {}
    local cur_spells = nil
    if selected_wand then
        cur_spells = selected_wand:children()
        if cur_spells then
            for _, v in cur_spells:ipairs() do
                local slot = v.ItemComponent.inventory_slot
                cur_wand_spells[slot.x + 1] = v
            end
        end
    end
    holder.Inventory2Component.mForceRefresh = true
end

UpdateWands()
UpdateStorage()

local always_open = ModSettingGet("azoth.bag_holding.always_open")
async_loop(function()
    if not gui.handle then
        wait(0)
        return
    end
    deck_item = Entity.Current()
    holder = deck_item:root()
    gui.player = holder
    local invgui = holder.InventoryGuiComponent
    if not invgui or not (always_open or invgui.mActive) then
        wait(0)
        return
    end
    inventory = holder:children():search(function(ent) return ent:name() == "inventory_full" end)

    wands = {}
    local wandlist = GetWands(holder)
    if wandlist then
        for _, wand in wandlist:ipairs() do
            local slot = wand.ItemComponent.inventory_slot
            wands[slot.x + 1] = wand
        end
    end
    spellbar = {}
    local cards = inventory:children()
    if cards then
        for _, card in cards:ipairs() do
            local slot = card.ItemComponent.inventory_slot
            spellbar[slot.x + 1] = card
        end
    end
    if deck_item.var_bool.update_wands then
        UpdateWands()
        deck_item.var_bool.update_wands = false
    end
    if deck_item.var_bool.update_deck then
        UpdateStorage()
        deck_item.var_bool.update_deck = false
    end
    gui:render()
    wait(0)
end)
