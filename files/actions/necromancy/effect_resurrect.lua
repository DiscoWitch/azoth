dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
local parent = self:parent()
if not parent then
    return
end
local genome = parent.GenomeDataComponent
if genome then
    genome.herd_id = StringToHerdId("player")
    parent.var_bool.necromancy_dying = false
    parent.var_bool.resurrected = true
end
local ai = parent.AnimalAIComponent
if ai then
    ai.dont_counter_attack_own_herd = true
    ai.aggressiveness_min = 100
    ai.aggressiveness_max = 100
    ai.escape_if_damaged_probability = 0
    local x, y = GameGetCameraPos()
    ai.mHomePosition = {
        x = x,
        y = y
    }
    ai.max_distance_to_move_from_home = 50
end
parent:removeTag("homing_target")
