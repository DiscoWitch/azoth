local entity = GetUpdatedEntityID();
local x, y = EntityGetTransform(entity);

local parent = EntityGetParent(entity);
local holder = EntityGetParent(parent);
if holder ~= nil then
    local now = GameGetFrameNum();
    local controls = EntityGetFirstComponent(holder, "ControlsComponent");
    if controls ~= nil then
        local fire = ComponentGetValue(controls, "mButtonDownAction");
        local fire_frame = ComponentGetValue(controls, "mButtonFrameAction");
        if fire == "1" and tonumber(fire_frame) == now then

            print("rope 1!")

        end

        local alt_fire = ComponentGetValue(controls, "mButtonDownThrow");
        local alt_fire_frame = ComponentGetValue(controls, "mButtonFrameThrow");
        if alt_fire == "1" and tonumber(alt_fire_frame) == now then

            print("rope 2!")

        end
    end
end
