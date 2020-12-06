dofile_once("mods/azoth/files/lib/disco_util/disco_util.lua")

local self = Entity.Current()
local parent = self:parent()
local x, y = parent:transform()
local angle = math.random() * 2 * math.pi
self:setTransform(x, y, angle)
