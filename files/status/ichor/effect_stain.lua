dofile_once("mods/azoth/files/lib/disco_util.lua")

function init(self)
    if self.var_bool.initialized then
        return
    end
    local parent = self:parent()
    local reapply = self:findChildren(function(ent)
        return ent:name() == "azoth_ichor_reapply"
    end)
    if not reapply then
        LoadGameEffectEntityTo(parent:id(), "mods/azoth/files/status/ichor/effect_reapply.xml")
    end
    self.var_bool.initialized = true
end

local self = Entity(GetUpdatedEntityID())
local parent = self:parent()

-- Make sure we're getting the right parent
if not parent then
    return
end
init(self)

-- Anger the gods if something ichored is in the holy mountain
local x, y = self:transform()
print(GlobalsGetValue("TEMPLE_SPAWN_GUARDIAN"))
if BiomeMapGetName(x, y) == "$biome_holymountain" and GlobalsGetValue("TEMPLE_SPAWN_GUARDIAN") ~= "1" then
    GlobalsSetValue("TEMPLE_SPAWN_GUARDIAN", "1")
    local guard_spawn_id = EntityGetClosestWithTag(x, y, "guardian_spawn_pos")
    if guard_spawn_id ~= 0 then
        local guard_x, guard_y = EntityGetTransform(guard_spawn_id)
        EntityKill(guard_spawn_id)
        EntityLoad("data/entities/misc/spawn_necromancer_shop.xml", guard_x, guard_y)
    end
    GamePrintImportant("$logdesc_temple_spawn_guardian", "")
    GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/angered_the_gods/create", x, y)
    GameScreenshake(150)
end
