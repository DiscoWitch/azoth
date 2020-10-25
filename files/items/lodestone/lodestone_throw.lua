dofile_once("mods/azoth/files/lib/goki_variables.lua")

function throw_item(from_x, from_y, to_x, to_y)
    local self = GetUpdatedEntityID()
    EntitySetVariableNumber(self, "throw_frame", GameGetFrameNum())
end
