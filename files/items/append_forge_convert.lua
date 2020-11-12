dofile_once("mods/azoth/files/lib/disco_util.lua")

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)

converted = false
for _, id in ipairs(EntityGetInRadiusWithTag(pos_x, pos_y, 70, "forgeable")) do
    local fdata = Entity(id)
    local item = fdata:parent()
    -- make sure item is not carried in inventory or wand
    if fdata:name() == "azoth_forge_data" and fdata:root():id() == item:id() then
        local forge_script = fdata.var_str.forge
        if forge_script then
            -- Get the script determining what to create from the item forge data
            local forge_check = dofile_once(forge_script)
            if forge_check.can_convert(fdata) then
                forge_check.convert(fdata)
            end
        end
    end
end
if converted then
    GameTriggerMusicFadeOutAndDequeueAll(3.0)
    GameTriggerMusicEvent("music/oneshot/dark_01", true, pos_x, pos_y)
end
