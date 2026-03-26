if script.active_mods["gvv"] then require("__gvv__.gvv")() end
util = require("utils")
sg_guis = require("logic.gui")
mod_gui = require("mod-gui")
glib = require("__glib__/glib")

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
local sgOffset = {x = 0, y = 1}
--at start check for existing char tables
--regen when not existing
--otherwise generate on surface generation


stargate = {
	Connect = function(thisGate, otherGate)
        activateGate(thisGate)
        activateGate(otherGate)
        game.print("Gates connected: "..thisGate.id.."|"..otherGate.id)
	end,
}

function activateGate(gate)
    gate.active = true
    gate.destination = gate
    util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_open")
    gate.animation = rendering.draw_animation{
        animation = "kj_stargate_eventHorizon",
        target = gate.entity.position,
        surface = gate.entity.surface,
    }
end

function OnLoad(e)
	if storage.stargate then
		for _, surface in pairs(storage.stargate) do
            for _, gate in pairs(surface) do
                setmetatable(gate, {__index = stargate})
            end
		end
	end

	util.mtMgr.OnLoad()
end

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
        local pos = ent.position
        local surface = ent.surface
        local tpArea = surface.create_entity{
            name = sgNames.tpArea,
            position = util.vector2Add(pos, {x = 0, y = -1.8}),
        }
        local childs = {
            baseEnt = surface.create_entity{
                name = sgNames.base,
                position = pos,
            },
            colliderV1 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = -3.5, y = -1}),
            },
            colliderV2 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = 3.5, y = -1}),
            },
            colliderH11 = surface.create_entity{
                name = sgNames.colliderH1,
                position = util.vector2Add(pos, {x = 0, y = -2.275}),
            },
            colliderH21 = surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(pos, {x = -2.5, y = -0.5}),
            },
            colliderH22 = surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(pos, {x = 2.5, y = -0.5}),
            },
            colliderH31 = surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(pos, {x = -2.25, y = -1.6}),
            },
            colliderH32 = surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(pos, {x = 2.25, y = -1.6}),
            },
            colliderD1 = surface.create_entity{
                name = sgNames.colliderD,
                position = util.vector2Add(pos, {x = -2.366, y = 0.225}),
                direction = defines.direction.southeast,
            },
            colliderD2 = surface.create_entity{
                name = sgNames.colliderD,
                position = util.vector2Add(pos, {x = 2.366, y = 0.225}),
                direction = defines.direction.southwest,
            },
        }

        for _, child in pairs(childs) do
            child.destructible = false
        end

        local posis = {x = {-0.5, -1.5}, y = {0, 1, 2}}
        local calcPosis = {}
        for i = 1, -1, -2 do
            for _, x in pairs(posis.x) do
                for _, y in pairs(posis.y) do
                    table.insert(calcPosis, {position = util.vector2Add(pos, {x*i,y}), name = "kj_stargate_slowDownTile"})
                end
            end
        end
        table.insert(calcPosis, {position = util.vector2Add(pos, {-2.5, 2}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, { 2.5, 2}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, {-2.5, 1}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, { 2.5, 1}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, {-3.5, 2}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, { 3.5, 2}), name = "kj_stargate_slowDownTile"})

        local oldTiles = {}
        for _, tile in pairs(calcPosis) do
            tile = surface.get_tile(tile.position.x, tile.position.y)
            table.insert(oldTiles, {name = tile.name, position = tile.position})
        end

        surface.set_tiles(calcPosis)

        local content = {
            valid = true,
            childs = childs,
            active = false,
            oldTiles = oldTiles,
            destination = nil,
        }
        util.addToGlobal("stargate", tpArea, content)

        ent.destroy()
    elseif ent.name == dhdName then --dhd placed
        ent.destructible = false
        local dhd = util.addToGlobal("dhd", ent)
    end
end

function OnRemoved(e)
	local ent = e.entity
    if not ent.valid then return end
    game.print("Removed "..ent.name)

	if ent.name == sgNames.tpArea then
        local sg = util.findInGlobal("stargate", ent)
        if sg.oldTiles then
            ent.surface.set_tiles(sg.oldTiles)
        end

        util.removeFromGlobal("stargate", ent)

    elseif ent.name == dhdName then
        local stargate = util.removeFromGlobal("dhd", ent)

        if stargate ~= nil then
            stargate.active = false
            util.playSoundOnSurface(ent.surface, stargate.entity.position, "kj_stargate_close")
            if stargate.animation then stargate.animation.destroy() end
        end
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
            if gate.active == true then
                if util.positionInBoundingBox(player.position, gate.entity.bounding_box) == true then
                    game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                    if player.vehicle and player.vehicle.prototype.type == "spider-vehicle" then
                        return
                    end
                    tempRandomTP(player, player.vehicle)
                end
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

function GuiOpened(e)
    game.print("Gui opened")
    local player = game.players[e.player_index]

    if e.entity and e.entity.name == "kj_dhd" then
        game.print("DHD opened")
        local dhd, id = util.findInGlobal("dhd", e.entity)
        if dhd == nil or dhd.stargate == nil then
            player.opened = nil
            return
        end

        gui = player.gui.screen.dhd
        local refs
        if not gui then
            gui, refs = glib.add(player.gui.screen, sg_guis.dhd_frame("dhd", {"dhd"}))
        else
            gui.visible = true
        end

        if refs.stargates then
            AssembleGatesInDHDGUI(refs.stargates, id)
        end

        gui.force_auto_center()
        gui.bring_to_front()
        player.opened = gui
    end
end

function AssembleGatesInDHDGUI(root, currentGate)
    if storage.stargate == nil then return end
    for sName, surface in pairs(storage.stargate) do
        for id, _ in pairs(surface) do
            glib.add(root, sg_guis.dhd_element(id, sName, currentGate))
        end
    end
end

script.on_event(defines.events.on_player_changed_position, OnPlayerMoved)

script.on_event(defines.events.on_built_entity, OnBuilt)
script.on_event(defines.events.on_robot_built_entity, OnBuilt)

script.on_load(OnLoad)
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

script.on_event(defines.events.on_gui_opened, GuiOpened)

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