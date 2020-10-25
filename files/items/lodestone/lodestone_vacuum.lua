local self = GetUpdatedEntityID();
local my_pc = EntityGetFirstComponent(self, "ProjectileComponent");
local stone = ComponentGetValue2(my_pc, "mWhoShot")

local my_wallet = EntityGetFirstComponentIncludingDisabled(self, "WalletComponent")
local stone_wallet = EntityGetFirstComponentIncludingDisabled(stone, "WalletComponent")

local my_money = ComponentGetValue2(my_wallet, "money")
if my_money > 0 then
    local stone_money = ComponentGetValue2(stone_wallet, "money")
    ComponentSetValue2(stone_wallet, "money", stone_money + my_money)
    ComponentSetValue2(my_wallet, "money", 0)
end
