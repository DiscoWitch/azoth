dofile_once("data/scripts/lib/utilities.lua")

function init(self)
    local x, y = EntityGetTransform(self)
    SetRandomSeed(x, y)
end

local self = GetUpdatedEntityID();
local x, y = EntityGetTransform(self);
local parent = EntityGetParent(self);
local holder = EntityGetParent(parent);
if holder ~= nil then
    local now = GameGetFrameNum();
    local controls = EntityGetFirstComponent(holder, "ControlsComponent");
    if controls ~= nil then
        local alt_fire = ComponentGetValue2(controls, "mButtonDownThrow");
        if alt_fire == true then
            local fullness = ComponentGetValue2(EntityGetFirstComponent(self, "MaterialSuckerComponent"), "mAmountUsed")
            local barrel_size = ComponentGetValue2(EntityGetFirstComponent(self, "MaterialSuckerComponent"),
                                    "barrel_size")
            if fullness < barrel_size then
                local vx, vy = ComponentGetValue2(controls, "mAimingVectorNormalized");
                vx = vx + 0.5 * (Random() - 0.5)
                vy = vy + 0.5 * (Random() - 0.5)
                shoot_projectile(self, "mods/azoth/files/items/flasks/flask_vacuum_projectile.xml", x, y, vx * 800,
                    vy * 800, true)
            end
        end
    end
end
