dofile_once("mods/azoth/files/lib/disco_util.lua")
local polytools = dofile_once("mods/azoth/files/lib/polytools/polytools.lua")

function damage_received(damage, message, entity_thats_responsible, is_fatal)
    local self = Entity.Current()
    if is_fatal then
        local genome = self.GenomeDataComponent
        if not genome or genome.herd_id == StringToHerdId("player") then return end
        local dmc = self.DamageModelComponent
        if dmc.ragdoll_filenames_file == "" then return end
        local x, y = self:transform()
        local ragdoll = Entity(EntityLoad("mods/azoth/files/actions/necromancy/ragdollgen.xml", x,
                                          y - 10))
        ragdoll.DamageModelComponent.ragdoll_filenames_file = dmc.ragdoll_filenames_file

        dmc.hp = dmc.max_hp + damage
        dmc.invincibility_frames = 10
        genome.herd_id = StringToHerdId("player")
        local ai = self.AnimalAIComponent
        if ai then
            ai.dont_counter_attack_own_herd = true
            ai.aggressiveness_min = 100
            ai.aggressiveness_max = 100
            ai.escape_if_damaged_probability = 0
        end
        self:removeTag("homing_target")
        self:addGameEffect("mods/azoth/files/actions/necromancy/effect_resurrect.xml")
        polytools.hide(self, -1)
        EntityInflictDamage(ragdoll:id(), 1000, "DAMAGE_CURSE", "NONE", "NONE", 0, 0)
    end
end
