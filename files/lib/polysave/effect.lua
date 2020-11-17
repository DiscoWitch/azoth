dofile_once("mods/azoth/files/lib/disco_util.lua")
local self = Entity(GetUpdatedEntityID())
if not self or not self:alive() then
    print_error("no current polysave entity")
end
if self.var_bool.save_data then
    -- If true, save data to the variable
    local ent = Entity(self.var_int.save_data)
    if not ent or not ent:alive() then
        print_error("polysave data entity does not exist")
        return
    end
    local var_name = self.var_str.save_data
    ent.var_str[var_name] = self.GameEffectComponent.mSerializedData
elseif self.var_str.save_data then
    -- If false, load data from the variable to our data
    self.GameEffectComponent.mSerializedData = self.var_str.save_data
end
