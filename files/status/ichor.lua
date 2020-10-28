dofile_once("mods/azoth/files/lib/goki_variables.lua")

function init(self)
    local initialized = EntityGetVariableNumber(self, "initialized", 0)
    if initialized ~= 0 then
        return
    end
    local parent = EntityGetRootEntity(self)
    local children = EntityGetAllChildren(parent);
    local is_applied = false
    for k, v in ipairs(children) do
        if EntityHasTag(v, "ichor_reapply") then
            is_applied = true
            break
        end
    end
    if not is_applied then
        LoadGameEffectEntityTo(parent, "mods/azoth/files/status/effect_ichor_reapply.xml")
    end
    EntitySetVariableNumber(self, "initialized", 1)
end

local self = GetUpdatedEntityID()
local parent = EntityGetRootEntity(self)

-- Make sure we're getting the right parent
if parent == self then
    return
end
init(self)

-- Ichor logic here
local x, y = EntityGetTransform(self)
local guard_spawn_id = EntityGetClosestWithTag(x, y, "guardian_spawn_pos")
if guard_spawn_id ~= 0 then
    GlobalsSetValue("TEMPLE_SPAWN_GUARDIAN", "1")
    local guard_x, guard_y = EntityGetTransform(guard_spawn_id)
    EntityKill(guard_spawn_id)
    EntityLoad("data/entities/misc/spawn_necromancer_shop.xml", guard_x, guard_y)
    GamePrintImportant("$logdesc_temple_spawn_guardian", "")
    GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/angered_the_gods/create", guard_x, guard_y)
    GameScreenshake(150)
end
