dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

function enabled_changed(entity_id, is_enabled)
    if is_enabled then
        local self = Entity.Current()
        self.var_bool.update_wands = true
    end
end
