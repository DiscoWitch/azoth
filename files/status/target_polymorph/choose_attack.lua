dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())

local parent = self:parent()
if not parent then
    return
end

if not parent.AIAttackComponent then
    return
end

if not self.var_bool.controls_initialized then
    local attacks = {0}
    for k, v in parent.AIAttackComponent:ipairs() do
        v:setEnabled(false)
        table.insert(attacks, v:id())
    end
    local attackstr = ""
    for k, v in ipairs(attacks) do
        attackstr = attackstr .. tostring(v) .. ","
    end
    self.var_str.attack_list = attackstr
    self.var_int.attack_list = 1
    -- Enable the first attack
    parent.AIAttackComponent:setEnabled(true)
    self.var_bool.controls_initialized = true
end

function str2table(input)
    local output = {}
    for i in string.gmatch(input, "([^,]+),") do
        table.insert(output, tonumber(i))
    end
    return output
end

local attacks = str2table(self.var_str.attack_list)
local attack_ind = self.var_int.attack_list
local controls = parent.ControlsComponent
if controls and controls.mButtonDownThrow and controls.mButtonFrameThrow == GameGetFrameNum() then
    if attacks[attack_ind] ~= 0 then
        EntitySetComponentIsEnabled(self:id(), attacks[attack_ind], false)
    end
    attack_ind = (attack_ind % #attacks) + 1
    self.var_int.attack_list = attack_ind
    if attacks[attack_ind] ~= 0 then
        EntitySetComponentIsEnabled(self:id(), attacks[attack_ind], true)
    end
    print("cycling attack: " .. attack_ind)
end
-- local ai = parent.AnimalAIComponent
-- if ai then
--     ai.attack_ranged_entity_file = attacks[attack_ind]
-- end
-- for k, v in parent.AIAttackComponent:ipairs() do
--     v.attack_ranged_entity_file = attacks[attack_ind]
-- end
