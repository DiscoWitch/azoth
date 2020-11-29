dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local inventory = self:parent()
local holder = inventory and inventory:parent()
local controls = holder and holder.ControlsComponent
if not controls then return end

function SwitchBar(offset)
    local cur_bar = self.var_int.cur_bar or 1
    local children = self:children()
    local max_bar = 0
    local bars = {}
    if children then
        for k, v in children:ipairs() do
            local bar_num = v.var_int.bar_num
            if bar_num then
                bars[bar_num] = v
                max_bar = math.max(max_bar, bar_num)
            end
        end
    end
    local cur_items =
        children and children:search(function(ent) return ent.ItemComponent ~= nil end)
    if cur_items then
        -- Find a space to put our items into
        bars[cur_bar] = Entity(EntityCreateNew("storage_bar"))
        bars[cur_bar]:setParent(self)
        bars[cur_bar].var_int.bar_num = cur_bar
        for k, v in cur_items:ipairs() do v:setParent(bars[cur_bar]) end
        cur_bar = cur_bar + offset
    else
        -- shift bars down into the gap if we're not filling it with anything
        for i = cur_bar, max_bar - 1 do
            bars[i] = bars[i + 1]
            bars[i].var_int.bar_num = i
        end
        if offset > 0 then
            cur_bar = cur_bar + offset - 1
        else
            cur_bar = cur_bar + offset
        end
    end
    if cur_bar < 1 then cur_bar = 1 end
    if bars[cur_bar] then
        for k, v in bars[cur_bar]:children():ipairs() do v:setParent(self) end
        bars[cur_bar]:kill()
    end
    self.var_int.cur_bar = cur_bar
end

local now = GameGetFrameNum()
if controls.mButtonDownFire and controls.mButtonFrameFire == now then
    SwitchBar(1)
elseif controls.mButtonDownThrow and controls.mButtonFrameThrow == now then
    SwitchBar(-1)
end
