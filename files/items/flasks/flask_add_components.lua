dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = Entity(GetUpdatedEntityID())
-- self:addTag("forgeable")
self:loadComponents("mods/azoth/files/items/flasks/flask_components.xml", true)
