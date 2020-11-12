local self = GetUpdatedEntityID()

-- Find the player who shot this and teleport to their cursor
local my_pc = EntityGetFirstComponent(self, "ProjectileComponent");
local shooter = ComponentGetValue2(my_pc, "mWhoShot")
if shooter == nil or shooter == 0 then
    return
end
local controls = EntityGetFirstComponent(shooter, "ControlsComponent")
if controls == 0 then
    return
end
local mousex, mousey = ComponentGetValue2(controls, "mMousePosition")

EntitySetTransform(self, mousex, mousey)
