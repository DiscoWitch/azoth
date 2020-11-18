dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local children = self:children()
if children then
    local contents = children:search(function(ent)
        return ent.ItemComponent ~= nil
    end)
    if contents then
        for k, v in contents:ipairs() do
            v:setEnabledWithTag("enabled_in_hand", false)
        end
        self.ItemComponent.uses_remaining = contents:len()
    else
        self.ItemComponent.uses_remaining = 0
    end
else
    self.ItemComponent.uses_remaining = 0
end
