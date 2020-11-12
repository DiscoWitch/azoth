dofile_once("data/scripts/gun/procedural/gun_action_utils.lua")
dofile_once("mods/azoth/files/lib/disco_util.lua")

-- Used to split the entity lists that were sent through storage
function str2table(input)
    local output = {}
    for i in string.gmatch(input, "([^,]+),") do
        table.insert(output, tonumber(i))
    end
    return output
end

-- Init code, called once at turret creation
local self = Entity(GetUpdatedEntityID())
local storage = Entity(EntityGetWithName("turret_storage"))
-- Populate our data table from storage
local src = {
    wand = Entity(tonumber(storage.variables.wand)),
    deck = str2table(storage.variables.deck),
    inventoryitem_id = str2table(storage.variables.inventoryitem_id)
}
-- kill storage now that we're done with it
storage:kill()

if src.wand == nil then
    print_error("No original wand found for turret")
    self:kill()
    return
end
local inv = self:findChildren(function(ent)
    return ent:name() == "inventory_quick"
end)[1]
local my_wand = inv:findChildren(function(ent)
    return ent:hasTag("wand")
end)[1]
if my_wand == nil then
    print_error("Turret couldn't find its own wand!")
    self:kill()
    return
end

-- Set my wand stats based on the wand that created me
WandCopy(src.wand, my_wand)
-- Populate the turret wand with copies of the spells recorded by the cast
for k, v in pairs(src.deck) do
    v = Entity(v)
    local action_entity = Entity(CreateItemActionEntity(v.ItemActionComponent.action_id))
    if action_entity ~= 0 then
        action_entity:setParent(my_wand)
        -- Set the turret copy to have the same number of uses as the original
        action_entity.ItemComponent.uses_remaining = v.ItemComponent.uses_remaining
        -- Link the turret to the same spell entry as the original
        action_entity.ItemComponent.mItemUid = src.inventoryitem_id[k]
        action_entity:setEnabledWithTag("enabled_in_world", false)
    end
end
