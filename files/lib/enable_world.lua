function enabled_changed(entity_id, is_enabled)
    if not is_enabled then
        -- Reeneable this luacomponent and set it to run one frame from now to enable everything else
        local self = entity_id
        local comp = GetUpdatedComponentID()
        if comp ~= 0 then
            EntitySetComponentIsEnabled(self, comp, true)
            ComponentSetValue2(comp, "execute_every_n_frame", 1)
        end
    end
end

-- Enable other components and then set this luacomponent to stop running while it's not needed
local self = GetUpdatedEntityID()
EntitySetComponentsWithTagEnabled(self, "enabled_in_world", true)
local comp = GetUpdatedComponentID()
if comp ~= 0 then
    ComponentSetValue2(comp, "execute_every_n_frame", -1)
end
