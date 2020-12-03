dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local storage = self:children():search(function(ent) return ent:name() == "spell_storage" end)
-- self.var_bool.edit_wands = true
for i = 1, 100 do
    local x = math.random()
    local y = math.random()
    local max_level = 6
    local action_id = GetRandomAction(x, y, max_level)
    local action = Entity(CreateItemActionEntity(action_id))
    action:setParent(storage)
end
