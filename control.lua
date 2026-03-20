if script.active_mods["gvv"] then require("__gvv__.gvv")() end
util = require("utils")

local sgName = "kj_stargate"
local sgOffset = {x = 0, y = 3}
--at start check for existing char tables
--regen when not existing
--otherwise generate on surface generation

function addAddressToGlobal(surface, address)
    if surface.platform ~= nil then return end
    if not storage.addresses then storage.addresses = {} end
    if not storage.addresses[surface.name] then storage.addresses[surface.name] = address end
end

function addGateToGlobal(entity)
    if not storage.stargates then storage.stargates = {} end
    local sName = entity.surface.name
    if not storage.stargates[sName] then storage.stargates[sName] = {} end
	table.insert(storage.stargates[sName], {
        entity = entity,
        pos = entity.position,
    })
	return entity
end

function removeGateFromGlobal(entity)
    if not storage.stargates then return end
    for i, sg in ipairs(storage.stargates) do
        if sg.entity == entity then
            storage.stargates[i] = nil
            return
        end
    end
end

function generateAdress(surface)
    --setting up rng
    local mapSeed = surface.map_gen_settings.seed
    local hash = util.hash_fnv1a(mapSeed..surface.name)
    local generator = game.create_random_generator(hash)
    game.print(surface.name.. " - Game Seed: "..mapSeed.." - Custom Seed: "..hash)

    --char table
    local chars = {}
    for i = string.byte("A"), string.byte("N") do
        table.insert(chars, string.char(i))
    end
    for i = string.byte("a"), string.byte("n") do
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
    for k in pairs(storage.stargates) do
        table.insert(surfaces, k)
    end
    local rSurface = surfaces[math.random(#surfaces)]

    local gates = {}
    for k in pairs(storage.stargates[rSurface]) do
        table.insert(gates, k)
    end
    local rGate = gates[math.random(#gates)]

    local pos = util.vector2Add(storage.stargates[rSurface][rGate].entity.position, sgOffset)
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

function OnPlayerMoved(e)
    if not storage.stargates then return end
    local player = game.players[e.player_index]
    --game.print(e.tick.." - Player "..player.name.." moved")
    if not storage.stargates[player.surface.name] then return end

    for _, gate in pairs(storage.stargates[player.surface.name]) do
        if util.positionInBoundingBox(player.position, gate.entity.bounding_box) == true then
            game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

            if player.vehicle and player.vehicle.prototype.type == "spider-vehicle" then
                return
            end
            tempRandomTP(player, player.vehicle)
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

function OnBuilt(e)
	local ent = e.entity

	if ent.valid and ent.name == sgName then
        game.print("Placed "..ent.name)

        addGateToGlobal(ent)
    end
end

function OnRemoved(e)
	local ent = e.entity

	if ent.valid and ent.name == sgName then
        game.print("Removed "..ent.name)

        removeGateFromGlobal(ent)
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