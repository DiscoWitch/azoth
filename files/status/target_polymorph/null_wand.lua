dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/gun/procedural/gun_action_utils.lua")

function throw_item(from_x, from_y, to_x, to_y)
    -- Kill the wand to make sure it's never possible for the player to get it
    EntityKill(GetUpdatedEntityID())
end

local wand = GetUpdatedEntityID()
local x, y = EntityGetTransform(wand)
SetRandomSeed(x, y - 11)

local ability_comp = EntityGetFirstComponent(wand, "AbilityComponent")

local gun = {}
gun.name = "Empty Hand"
gun.deck_capacity = 0
gun.actions_per_round = 1
gun.reload_time = 0
gun.shuffle_deck_when_empty = false
gun.fire_rate_wait = 0
gun.spread_degrees = 0
gun.speed_multiplier = 1
gun.mana_charge_speed = 0
gun.mana_max = 0

ComponentSetValue2(ability_comp, "ui_name", gun.name)
ComponentObjectSetValue2(ability_comp, "gun_config", "reload_time", gun.reload_time)
ComponentObjectSetValue2(ability_comp, "gunaction_config", "fire_rate_wait", gun.fire_rate_wait)
ComponentSetValue2(ability_comp, "mana_charge_speed", gun.mana_charge_speed)
ComponentObjectSetValue2(ability_comp, "gun_config", "actions_per_round", gun.actions_per_round)
ComponentObjectSetValue2(ability_comp, "gun_config", "deck_capacity", gun.deck_capacity)
ComponentObjectSetValue2(ability_comp, "gun_config", "shuffle_deck_when_empty", gun.shuffle_deck_when_empty)
ComponentObjectSetValue2(ability_comp, "gunaction_config", "spread_degrees", gun.spread_degrees)
ComponentObjectSetValue2(ability_comp, "gunaction_config", "speed_multiplier", gun.speed_multiplier)

ComponentSetValue2(ability_comp, "mana_max", gun.mana_max)
ComponentSetValue2(ability_comp, "mana", gun.mana_max)
