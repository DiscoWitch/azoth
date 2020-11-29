dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")
local self = Entity.Current()
local parent = self:parent()

-- Make sure we're getting the right parent
if not parent then
    print("no parent")
    return
end

local ents = parent:children()
local ichor_effects = ents
                          and ents:search(
                              function(ent) return ent:name() == "azoth_ichor_ingest" end)
if ichor_effects:len() > 1 then
    self:kill()
    return
end

if not parent.var_bool.ichor_ingest then
    -- Ichor effects
    local damagetypes = {
        "curse",
        "drill",
        "electricity",
        "explosion",
        "fire",
        "healing",
        "ice",
        "melee",
        "overeating",
        "physics_hit",
        "poison",
        "projectile",
        "radioactive",
        "slice"
    }
    for _, v in ipairs(damagetypes) do
        parent.DamageModelComponent.damage_multipliers[v] =
            0.1 * parent.DamageModelComponent.damage_multipliers[v]
    end
    parent.var_bool.ichor_ingest = true
end

