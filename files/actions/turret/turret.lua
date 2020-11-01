dofile_once("mods/azoth/files/lib/goki_variables.lua")
dofile_once("data/scripts/gun/procedural/gun_action_utils.lua")

-- Init code, called once at turret creation
local self = GetUpdatedEntityID()
local storage = EntityGetWithName("turret_storage")
-- Populate our data table immediately
local src = {
    wand = EntityGetVariableNumber(storage, "wand", 0),
    deck = EntityGetVariableString(storage, "deck", "")
}
-- kill storage now that we're done with it
EntityKill(storage)
EntitySetVariableNumber(self, "wand", src.wand)
EntitySetVariableString(self, "deck", src.deck)

if src.wand == 0 then
    print("No wand found for turret")
    EntityKill(self)
    return
end

local temp_deck = {}
for i in string.gmatch(src.deck, "([^,]+),") do
    table.insert(temp_deck, tonumber(i))
end
src.deck = temp_deck

-- Fill in the stats of our wand
local inv = nil
for k, v in ipairs(EntityGetAllChildren(self)) do
    if EntityGetName(v) == "inventory_quick" then
        inv = v
        break
    end
end
local my_wand = nil
for k, v in ipairs(EntityGetAllChildren(inv)) do
    if EntityHasTag(v, "wand") then
        my_wand = v
        break
    end
end
if my_wand == nil or my_wand == 0 then
    EntityKill(self)
    return
end
for k, v in pairs(src.deck) do
    local iac = EntityGetFirstComponentIncludingDisabled(v, "ItemActionComponent")
    local action = ComponentGetValue2(iac, "action_id")
    local action_entity_id = CreateItemActionEntity(action)
    if action_entity_id ~= 0 then
        EntityAddChild(my_wand, action_entity_id)
        local new_ic = EntityGetFirstComponentIncludingDisabled(action_entity_id, "ItemComponent")
        local ic = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
        local orig_uses = ComponentGetValue2(ic, "uses_remaining")
        ComponentSetValue2(new_ic, "uses_remaining", orig_uses)
        EntitySetComponentsWithTagEnabled(action_entity_id, "enabled_in_world", false)
        EntitySetVariableNumber(action_entity_id, "original", v)
    end
end

-- Set my wand stats based on the wand that created me
local names_ac = {"ui_name", "mana_max", "mana", "mana_charge_speed"}
local src_ac = EntityGetFirstComponentIncludingDisabled(src.wand, "AbilityComponent")
local my_ac = EntityGetFirstComponent(my_wand, "AbilityComponent")
for index, name in ipairs(names_ac) do
    local val = ComponentGetValue2(src_ac, name)
    ComponentSetValue2(my_ac, name, val)
end
local names_gunconfig = {"reload_time", "actions_per_round", "deck_capacity", "shuffle_deck_when_empty"}
for index, name in ipairs(names_gunconfig) do
    local val = ComponentObjectGetValue2(src_ac, "gun_config", name)
    ComponentObjectSetValue2(my_ac, "gun_config", name, val)
end
local names_gunactionconfig = {"fire_rate_wait", "spread_degrees", "speed_multiplier"}
for index, name in ipairs(names_gunactionconfig) do
    local val = ComponentObjectGetValue2(src_ac, "gunaction_config", name)
    ComponentObjectSetValue2(my_ac, "gunaction_config", name, val)
end

-- Set a target in front of the wand for firing purposes
local x, y = EntityGetTransform(self)
EntityAddChild(self, EntityLoad("mods/azoth/files/actions/turret/target.xml", x, y))
