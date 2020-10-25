dofile_once("mods/azoth/files/lib/goki_variables.lua")

local self = GetUpdatedEntityID();
local knot1 = EntityGetVariableNumber(self, "knot1", 0);
local knot2 = EntityGetVariableNumber(self, "knot2", 0);

if EntityGetIsAlive(knot1) and EntityGetIsAlive(knot2) then
    -- Zip back and forth along the rope to draw a trail along it
    local cur_knot = knot1
    if GameGetFrameNum() % 2 == 0 then
        cur_knot = knot2
    end
    local pos_x, pos_y, rotation = EntityGetTransform(cur_knot)
    EntitySetTransform(self, pos_x, pos_y, rotation)
else
    -- If either side of the tether is destroyed, destroy the tether effect too
    EntityKill(self)
end
