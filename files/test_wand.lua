dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/gun/procedural/gun_action_utils.lua")

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)
SetRandomSeed(x, y - 11)

local ability_comp = EntityGetFirstComponent(entity_id, "AbilityComponent")

local gun = {}
gun.name = "Test wand"
gun.deck_capacity = 25
gun.actions_per_round = 1
gun.reload_time = 0
gun.shuffle_deck_when_empty = false
gun.fire_rate_wait = 15
gun.spread_degrees = 0
gun.speed_multiplier = 1
gun.mana_charge_speed = 1000
gun.mana_max = 1000

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

-- AddGunActionPermanent( entity_id, gun_action )
AddGunAction(entity_id, "ELECTRIC_CHARGE")
AddGunAction(entity_id, "LIGHT_BULLET")
