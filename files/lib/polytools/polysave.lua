dofile_once("mods/azoth/files/lib/disco_util.lua")
local base64 = dofile_once("mods/azoth/files/lib/polysave/base64.lua")

local self = Entity(GetUpdatedEntityID())
if not self or not self:alive() then
    print_error("no current polysave entity")
end

if self.var_bool.save_data then
    -- Save data to the variable
    local ent = Entity(self.var_int.save_data)
    if not ent or not ent:alive() then
        print_error("polysave data entity does not exist")
        return
    end
    local var_name = self.var_str.save_data
    ent.var_str[var_name] = self.GameEffectComponent.mSerializedData
end
if self.var_bool.load_data then
    -- Load data from the variable to our data
    self.GameEffectComponent.mSerializedData = self.var_str.load_data
end

function BytesToInt(b1, b2, b3, b4, big_endian)
    if big_endian then
        return b1 + b2 * 0x100 + b3 * 0x10000 + b4 * 0x1000000
    else
        return b4 + b3 * 0x100 + b2 * 0x10000 + b1 * 0x1000000
    end
end
if self.var_bool.save_path then
    -- If true, save data to the variable
    local ent = Entity(self.var_int.save_path)
    if not ent or not ent:alive() then
        print_error("polysave data entity does not exist")
        return
    end
    local var_name = self.var_str.save_path
    local data = base64.decodeToNumbers(self.GameEffectComponent.mSerializedData)
    -- Iterate through the header to get the name and path
    local i = 1
    local namesize = BytesToInt(data[i], data[i + 1], data[i + 2], data[i + 3])
    -- Advance 4 bytes then discard name including null terminator
    i = i + 4 + namesize + 1
    local pathsize = BytesToInt(data[i], data[i + 1], data[i + 2], data[i + 3])
    i = i + 4
    local path = ""
    if pathsize > 0 then
        for j = i, i + pathsize do
            path = path .. string.char(data[j])
            i = j
        end
    end
    print("path: " .. path)
    ent.var_str[var_name] = path
end
