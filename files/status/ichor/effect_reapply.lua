dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local parent = self:parent()

-- Make sure we're getting the right parent
if not parent then return end

local stain_rate = self.var_int.stain_rate or 20

-- Logic to reduce stain_rate
local fire = GameGetGameEffect(parent:id(), "ON_FIRE")
local oiled = GameGetGameEffect(parent:id(), "OILED")
if (fire ~= 0 or oiled ~= 0) and stain_rate > 0 then
    stain_rate = stain_rate - 1
    self.var_int.stain_rate = stain_rate
    if stain_rate <= 0 then
        self:kill()
        return
    end
end

-- Reapply ichor to prevent washing it off easily
local ichor = CellFactory_GetType("azoth_ichor")
EntityAddRandomStains(parent:id(), ichor, stain_rate)

