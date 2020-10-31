function interacting(actor, self, plant_xml)
    local x, y = EntityGetTransform(self)
    EntityLoad(plant_xml, x, y)
    EntityKill(self)
end
