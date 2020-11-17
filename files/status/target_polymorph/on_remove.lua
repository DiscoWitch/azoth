dofile_once("mods/azoth/files/lib/disco_util.lua")
dofile_once("data/scripts/game_helpers.lua")

local self = Entity(GetUpdatedEntityID())
local parent = self:parent()
if not parent then
    return
end

local is_player = parent.GameStatsComponent and parent.GameStatsComponent.is_player

if not is_player then
    return
end

-- This runs right before polymorph wears off
local x, y = parent:transform()
if parent.WalletComponent then
    -- Drop all of our money as BIG NUGGET
    local money = parent.WalletComponent.money
    if money > 0 then
        local nugget = Entity(EntityLoad("mods/azoth/files/status/target_polymorph/nugget.xml", x, y))
        nugget.var_int.gold_value = money
    end
end

if parent.DamageModelComponent then
    -- Drop a heart worth the amount of max health we've gained
    local maxhp = parent.DamageModelComponent.max_hp
    local maxhp_old = self.var_float.maxhp_start
    if maxhp_old and maxhp - maxhp_old > 1 / 25 then
        local heart = Entity(EntityLoad("mods/azoth/files/status/target_polymorph/heart.xml", x, y))
        heart.var_float.health_value = maxhp - maxhp_old
    end
end
