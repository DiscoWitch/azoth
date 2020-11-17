dofile_once("mods/azoth/files/lib/disco_util.lua")
local self = Entity(GetUpdatedEntityID())
local parent = self:parent()
if not parent then
    return
end
if parent:name() == "polynull" then
    return
end

-- Destroy all components from the polymorph sheep to make room for the new creature
local comps = parent:allComponents()
if comps then
    local blacklist = {
        ControlsComponent = true
    }
    for k, v in comps:ipairs() do
        local name = v:type()
        if name == "GameStatsComponent" then
            v.extra_death_msg = ", while hidden"
        elseif blacklist[name] then
            -- Do nothing
        else
            v:remove()
        end
    end
end

-- Load in the new creature over the sheep
local polytarget = self.GameEffectComponent.polymorph_target
parent:loadComponents(polytarget, true, true, true)
