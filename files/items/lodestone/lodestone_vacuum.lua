dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local stone = Entity(self.ProjectileComponent.mWhoShot)
local my_money = self.WalletComponent.money
if my_money > 0 then
    stone.WalletComponent.money = stone.WalletComponent.money + my_money
    self.WalletComponent.money = 0
end
