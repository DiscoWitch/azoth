dofile_once("data/scripts/lib/coroutines.lua");
dofile_once("data/scripts/lib/utilities.lua");
dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local gui = gui or GuiCreate();

local value = value or "test"

local function pack(...) return {...} end

async_loop(function()
    if not gui then
        if pause_effect then pause_effect.GameEffectComponent.frames = 0 end
        wait(0)
        return
    end
    local self = Entity.Current()
    local holder = self:root()

    local pause_effect = holder:children():search(function(ent)
        return ent:name() == "azoth_pause"
    end)

    local inventory = holder.InventoryGuiComponent
    if not inventory or not inventory.mActive then
        if pause_effect then pause_effect.GameEffectComponent.frames = 0 end
        wait(0)
        return
    end
    local disable_controls = false

    GuiStartFrame(gui)

    local x = 72
    local y = 4
    GuiLayoutBeginHorizontal(gui, x, y)
    GuiLayoutBeginVertical(gui, 0, 0)
    local clicked, rclicked = GuiImageButton(gui, 1, 0, 0, "",
                                             "mods/azoth/files/items/deck/arrow_up.png")
    local clicked2, rclicked2 = GuiImageButton(gui, 2, 0, 0, "",
                                               "mods/azoth/files/items/deck/arrow_down.png")
    if clicked then print("clicked!") end
    if rclicked then print("rclicked!") end
    if clicked2 then print("clicked2!") end
    if rclicked2 then print("rclicked2!") end
    GuiLayoutEnd(gui)
    local value_new = GuiTextInput(gui, 3, 2, 5, value, 45, 15, "")
    value = value_new

    local text_info = pack(GuiGetPreviousWidgetInfo(gui))
    if text_info[3] == 1 then disable_controls = true end
    GuiLayoutEnd(gui)

    if disable_controls then
        if not pause_effect then
            holder:addGameEffect("mods/azoth/files/status/pause/effect.xml")
        end
    elseif pause_effect then
        pause_effect.GameEffectComponent.frames = 0
    end
    wait(0)
end)
