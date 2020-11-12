dofile_once("mods/azoth/files/lib/disco_util.lua")
local self = Entity(GetUpdatedEntityID())
local parent = self:parent()
if not parent then
    return
end

local is_player = false

-- Destroy all components from the polymorph sheep to make room for the new creature
for k, v in parent:allComponents():ipairs() do
    local name = v:type()
    if name == "GameStatsComponent" then
        is_player = v.is_player
        v.extra_death_msg = ", while polymorphed"
    elseif name == "ControlsComponent" or name == "FogOfWarRadiusComponent" then
        -- Do nothing
    else
        v:remove()
    end
end

-- Load in the new creature over the sheep
local polytarget = self.GameEffectComponent.polymorph_target
parent:loadComponents(polytarget, true)
local add_components = self.var_str.add_components
if add_components and add_components ~= "" then
    -- Scripts applying this effect can point to an xml with extra components to add (eg new attacks)
    parent:loadComponents(add_components, true)
end

-- All parts below are for player controls, so don't do them for enemies
if not is_player then
    return
end

-- Turn off all AI components to prevent interference with the player controls
local animal_ai = parent.AnimalAIComponent
if animal_ai then
    for k, v in animal_ai:ipairs() do
        v:setEnabled(false)
    end
end

local keep_ui = self.var_bool.keep_ui
local worm_ai = parent.WormAIComponent
if worm_ai then
    -- Turn off the worm AI and add a worm player controller
    for k, v in worm_ai:ipairs() do
        v:setEnabled(false)
    end
    parent:addComponent("WormPlayerComponent", {
        _enabled = true
    })

    if keep_ui then
        -- Kill components so the game doesn't crash when they player components are added
        parent:removeComponents({"CameraBoundComponent", "CharacterCollisionComponent", "ControlsComponent",
                                 "ItemPickUpperComponent", "ItemChestComponent"})

        -- Parts to enable the health bar and inventory
        parent:loadComponents("mods/azoth/files/status/target_polymorph/player_base_worm.xml", true)
    end
else
    if keep_ui then
        -- Kill components so the game doesn't crash when they player components are added
        parent:removeComponents({"CameraBoundComponent", "CharacterDataComponent", "CharacterPlatformingComponent",
                                 "CharacterCollisionComponent", "ControlsComponent", "ItemPickUpperComponent",
                                 "ItemChestComponent"})
        -- Add components to make controls more player-like
        parent:loadComponents("mods/azoth/files/status/target_polymorph/player_base.xml", true)
    end

    -- Script for choosing different rangedd attacks from the creature
    self:addComponent("LuaComponent", {
        execute_every_n_frame = 1,
        script_source_file = "mods/azoth/files/status/target_polymorph/choose_attack.lua"
    })
end

-- Script to depoly instead of dying on lethal damage
if self.var_bool.end_on_death then
    parent:addComponent("LuaComponent", {
        execute_every_n_frame = -1,
        script_damage_received = "mods/azoth/files/status/target_polymorph/saving_grace.lua"
    })
end