dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

function GetQuickSlotPos(slot_num, is_wand)
    local x0 = (is_wand and 29) or 110
    local y0 = 30
    local dx = 20
    return x0 + slot_num * dx, y0
end
function GetFullSlotPos(slot_x, slot_y)
    slot_y = slot_y or 0
    local x0 = 200
    local y0 = 30
    local dx = 20
    local dy = 20
    return x0 + slot_x * dx, y0 + slot_y * dy
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

function GuiImageCentered(gui, id, x, y, sprite_filename, alpha, scale, rotation)
    local w, h = GuiGetImageDimensions(gui, sprite_filename, scale)
    x = x - w / 2
    y = y - h / 2
    return GuiImage(gui, id, x, y, sprite_filename, alpha, scale, rotation)
end

function GuiImageButtonCentered(gui, id, x, y, text, sprite_filename)
    local w, h = GuiGetImageDimensions(gui, sprite_filename, 1)
    x = x - w / 2
    y = y - h / 2
    return GuiImageButton(gui, id, x, y, text, sprite_filename)
end
