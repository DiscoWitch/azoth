dofile_once("mods/azoth/files/items/containers/inventory_utils.lua")

function enabled_changed(entity_id, is_enabled)
    if is_enabled then
        DetachStorage()
    else
        ReattachStorage()
    end
end
