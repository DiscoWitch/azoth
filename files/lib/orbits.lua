function get_orbit(radius, speed)
    local f = speed ^ 2 / radius
    local force_const = f / radius
    local friction = force_const / 60
    return force_const, friction
end
