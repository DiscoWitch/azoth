dofile_once("mods/azoth/files/lib/disco_util.lua")

function throw_item(from_x, from_y, to_x, to_y)
    local self = Entity.Current()
    self.var_int.phase = 0
    self:setEnabledWithTag("disabled_during_throw", false)
end
