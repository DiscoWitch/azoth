dofile_once("mods/azoth/files/lib/disco_util.lua")
local polytools = dofile_once("mods/azoth/files/lib/polytools.lua")
local self = Entity(GetUpdatedEntityID())
polytools.load(self, self.var_str.polydata)
