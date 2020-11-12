dofile_once("mods/azoth/files/lib/disco_util.lua")

function collision_trigger(colliding_entity_id)
    local x, y = EntityGetTransform(GetUpdatedEntityID())

    -- abort if conversion already in progress
    if #EntityGetInRadiusWithTag(x, y, 10, "forge_item_convert") > 0 then
        return
    end

    local fdata = Entity(colliding_entity_id)
    local item = fdata:parent()
    -- make sure item is not carried in inventory or wand
    if fdata:name() == "azoth_forge_data" and fdata:root():id() == item:id() then
        local forge_script = fdata.var_str.forge
        if forge_script then
            -- Get the script determining what to create from the item forge data
            local forge_check = dofile_once(forge_script)
            if forge_check.can_convert(fdata) then
                -- start conversion
                EntityLoad("data/entities/buildings/forge_item_convert.xml", x, y)
                GamePlaySound("data/audio/Desktop/projectiles.snd", "projectiles/magic/create", x, y)
            end
        end
    end
end

