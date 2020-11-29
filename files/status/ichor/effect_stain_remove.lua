dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local parent = self:parent()

-- Make sure we're getting the right parent
if not parent then return end
local fire_prot = parent:children():search(function(ent)
    return ent.GameEffectComponent and ent.GameEffectComponent.effect == "PROTECTION_FIRE"
end)
if fire_prot then fire_prot.GameEffectComponent:setEnabled(true) end
