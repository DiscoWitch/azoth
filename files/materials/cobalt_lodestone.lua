local self = GetUpdatedEntityID()
local x, y = EntityGetTransform(self)
EntityLoad("mods/azoth/files/items/lodestone/lodestone.xml", x, y)
