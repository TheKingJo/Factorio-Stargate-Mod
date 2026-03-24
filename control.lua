if script.active_mods["gvv"] then require("__gvv__.gvv")() end
util = require("utils")

local sgNames = {
    placement = "kj_stargate_placement",
    base = "kj_stargate_base",
    tpArea = "kj_stargate_transferArea",
    colliderV = "kj_stargate_colliderVert",
    colliderH1 = "kj_stargate_colliderHori1",
    colliderH2 = "kj_stargate_colliderHori2",
    colliderD = "kj_stargate_colliderDiag",
}
local dhdName = "kj_dhd"
local sgOffset = {x = 0, y = 3}
--at start check for existing char tables
--regen when not existing
--otherwise generate on surface generation

function addAddressToGlobal(surface, address)
    if surface.platform ~= nil then return end
    if not storage.addresses then storage.addresses = {} end
    if not storage.addresses[surface.name] then storage.addresses[surface.name] = address end
end

function generateAdress(surface)
    --setting up rng
    local mapSeed = surface.map_gen_settings.seed
    local hash = util.hash_fnv1a(mapSeed..surface.name)
    local generator = game.create_random_generator(hash)
    game.print(surface.name.. " - Game Seed: "..mapSeed.." - Custom Seed: "..hash)

    --char table
    local chars = {}
    for i = string.byte("A"), string.byte("S") do
        table.insert(chars, string.char(i))
    end
    for i = string.byte("a"), string.byte("s") do
        table.insert(chars, string.char(i))
    end

    local result = {}
    for i = 1, 6 do
        local index = generator(1, #chars)
        result[i] = chars[index]
    end
    local resultString = table.concat(result)

    game.print("Adress: "..resultString)
    return resultString
end

function generateAdresses(e)
    for _, surface in pairs(game.surfaces) do
        addAddressToGlobal(surface, generateAdress(surface))
    end
end

function tempRandomTP(player, vehicle)
    local surfaces = {}
    for k in pairs(storage.stargate) do
        table.insert(surfaces, k)
    end
    local rSurface = surfaces[math.random(#surfaces)]

    local gates = {}
    for k in pairs(storage.stargate[rSurface]) do
        table.insert(gates, k)
    end
    local rGate = gates[math.random(#gates)]

    local pos = util.vector2Add(storage.stargate[rSurface][rGate].entity.position, sgOffset)
    player.teleport(
        pos,
        game.surfaces[rSurface]
    )
    if vehicle ~= nil then
        vehicle.teleport(
            pos,
            game.surfaces[rSurface]
        )
        --flip car in certain value ranges
        vehicle.orientation = (vehicle.orientation < 0.25 or vehicle.orientation > 0.75) and 0.5 or 0
    end

    if storage.players == nil then storage.players = {} end
    table.insert(storage.players, {tick = game.tick + 15, player = player})
end

function OnBuilt(e)
	local ent = e.entity
    if not ent.valid then return end
    game.print("Placed "..ent.name)

	if ent.name == sgNames.placement then --stargate placed
        local tpArea = ent.surface.create_entity{
            name = sgNames.tpArea,
            position = util.vector2Add(ent.position, {x = 0, y = -1.8}),
        }
        local childs = {
            baseEnt = ent.surface.create_entity{
                name = sgNames.base,
                position = ent.position,
            },
            colliderV1 = ent.surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(ent.position, {x = -3.5, y = -1}),
            },
            colliderV2 = ent.surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(ent.position, {x = 3.5, y = -1}),
            },
            colliderH11 = ent.surface.create_entity{
                name = sgNames.colliderH1,
                position = util.vector2Add(ent.position, {x = 0, y = -2.275}),
            },
            colliderH21 = ent.surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(ent.position, {x = -2.5, y = -0.5}),
            },
            colliderH22 = ent.surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(ent.position, {x = 2.5, y = -0.5}),
            },
            colliderH31 = ent.surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(ent.position, {x = -2.25, y = -1.6}),
            },
            colliderH32 = ent.surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(ent.position, {x = 2.25, y = -1.6}),
            },
            colliderD1 = ent.surface.create_entity{
                name = sgNames.colliderD,
                position = util.vector2Add(ent.position, {x = -2.366, y = 0.225}),
                direction = defines.direction.southeast,
            },
            colliderD2 = ent.surface.create_entity{
                name = sgNames.colliderD,
                position = util.vector2Add(ent.position, {x = 2.366, y = 0.225}),
                direction = defines.direction.southwest,
            },
        }

        for _, child in pairs(childs) do
            child.destructible = false
        end

        local content = {
            valid = true,
            childs = childs,
            active = false
        }
        util.addToGlobal("stargate", tpArea, content)
        local pos = ent.position
        local posis = {x = {-0.5, -1.5}, y = {0, -1, -2}}
        local calcPosis = {}
        for i = 1, -1, -2 do
            for _, x in pairs(posis.x) do
                for _, y in pairs(posis.y) do
                    table.insert(calcPosis, {position = util.vector2Add(pos, {x*i,y}), name = "kj_stargate_slowDownTile"})
                end
            end
        end
        game.print(serpent.block(calcPosis))
        ent.surface.set_tiles(calcPosis)
        --[[ent.surface.set_tiles({
            {position = util.vector2Add(pos, {0.5,  0}), name = "kj_stargate_slowDownTile"},
            {position = util.vector2Add(pos, {-0.5, 0}), name = "kj_stargate_slowDownTile"},
            {position = util.vector2Add(pos, {0.5, -1}), name = "kj_stargate_slowDownTile"},
            {position = util.vector2Add(pos, {-0.5,-1}), name = "kj_stargate_slowDownTile"},
            {position = util.vector2Add(pos, {1.5,  0}), name = "kj_stargate_slowDownTile"},
            {position = util.vector2Add(pos, {-1.5, 0}), name = "kj_stargate_slowDownTile"},
            {position = util.vector2Add(pos, {1.5, -1}), name = "kj_stargate_slowDownTile"},
            {position = util.vector2Add(pos, {-1.5,-1}), name = "kj_stargate_slowDownTile"},
        })]]
        ent.destroy()

    elseif ent.name == dhdName then --dhd placed
        ent.destructible = false
        util.addToGlobal("dhd", ent)
    end
end

function OnRemoved(e)
	local ent = e.entity
    if not ent.valid then return end
    game.print("Removed "..ent.name)

	if ent.name == sgNames.tpArea then
        util.removeFromGlobal("stargate", ent)

    elseif ent.name == dhdName then
        util.removeFromGlobal("dhd", ent)
    end
end

function OnPlayerMoved(e)
    if not storage.stargate then return end
    local player = game.players[e.player_index]
    --game.print(e.tick.." - Player "..player.name.." moved")
    if not storage.stargate[player.surface.name] then return end

    for i = #storage.stargate[player.surface.name], 1, -1 do
        local gate = storage.stargate[player.surface.name][i]

        if gate.valid == true and gate.entity and gate.entity.valid then
            if util.positionInBoundingBox(player.position, gate.entity.bounding_box) == true then
                game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                if player.vehicle and player.vehicle.prototype.type == "spider-vehicle" then
                    return
                end
                tempRandomTP(player, player.vehicle)
            end
        else
            table.remove(storage.stargate[player.surface.name], i)
        end
    end

    --[[
    on player moved:
        check all gates
            check if players are inside border
                teleport if yes
                also teleport vehicle
    ]]
end

function OnTick(e)
    if storage.players ~= nil then
        for i = #storage.players, 1, -1 do
            local player = storage.players[i]
            if game.tick < player.tick then
                player.player.walking_state = {
                    walking = true,
                    direction = 8
                }
            else
                table.remove(storage.players, i)
            end
        end
    end
end

script.on_event(defines.events.on_player_changed_position, OnPlayerMoved)

script.on_event(defines.events.on_built_entity, OnBuilt)
script.on_event(defines.events.on_robot_built_entity, OnBuilt)

--script.on_load(OnLoad)
--script.on_configuration_changed(OnConfigChanged)
--script.on_event(defines.events.on_tick, OnTick)

script.on_event(defines.events.on_player_mined_entity, OnRemoved)
script.on_event(defines.events.on_robot_mined_entity, OnRemoved)
script.on_event(defines.events.on_entity_died, OnRemoved)

script.on_event(defines.events.on_tick, OnTick)

script.on_event(defines.events.on_surface_created,
    function(event)
        local surface = game.surfaces[event.surface_index]
        addAddressToGlobal(surface, generateAdress(surface))
    end
)

script.on_init(generateAdresses)

--[[
/c
local rng = game.create_random_generator()
game.print("number: "..rng(1, 10))
game.print("number: "..rng(1, 10))
game.print("number: "..rng(1, 10))
game.print("number: "..rng(1, 10))
]]


--turn surface name into number and combine with map seed

--[[
    surface name + game seed -> seed
    ->generate adress
]]