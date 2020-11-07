function shot(projectile)
    local proj = EntityGetFirstComponent(projectile, "ProjectileComponent")
    ComponentSetValue2(proj, "damage", ComponentGetValue2(proj, "damage") * 5)
end
