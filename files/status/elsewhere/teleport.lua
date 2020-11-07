dofile_once("mods/azoth/files/lib/disco_util.lua")

local self = GetUpdatedEntityID()
local x, y = EntityGetTransform(self)

if not initialized then
    SetRandomSeed(x, y)
end

local ents = EntityGetWithTag("enemy")
local rand = Random()
local dist = 100
local type = "enemy"
if rand < 0.1 then
    ents = {}
    for k, v in ipairs(EntityGetWithTag("item_physics")) do
        if EntityGetParent(v) == 0 then
            print(EntityGetTags(v))
            table.insert(ents, v)
        end
    end
    type = "item"
    dist = 30
elseif rand < 0.2 then
    ents = EntityGetWithTag("prop_physics")
    type = "prop"
    dist = 30
end
if #ents == 0 then
    return
end
local ent = ents[Random(1, #ents)]
for i = 1, 10 do
    local tx = x + Random(-dist, dist)
    local ty = y + Random(-dist, dist)
    if i == 1 and type == "prop" then
        tx = x
        ty = y - 40
    end
    local did_hit = RaytraceSurfaces(tx, ty, tx, ty - 10)
    if not did_hit then
        local ox, oy = EntityGetTransform(ent)
        EntitySetTransform(ent, tx, ty)
        EntityApplyTransform(ent, tx, ty)
        local pbc = EntityGetFirstComponent(ent, "PhysicsBodyComponent")
        if pbc ~= 0 then
            if i == 1 and type == "prop" then
                PhysicsApplyForce(ent, 0, 500)
            else
                PhysicsApplyForce(ent, 0, -5)
            end
        end
        EntityLoad("data/entities/particles/teleportation_source.xml", ox, oy)
        EntityLoad("data/entities/particles/teleportation_target.xml", tx, ty)
        -- GamePlaySound("data/audio/Desktop/misc.bank", "misc/teleport_use", tx, ty)
        break
    end
end
