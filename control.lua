if script.active_mods["gvv"] then require("__gvv__.gvv")() end
util = require("utils")
sg_guis = require("logic.gui")
mod_gui = require("mod-gui")
glib = require("__glib__/glib")

local sgNames = {
    placement = "kj_stargate_placement",
    base = "kj_stargate_base",
    sound = "kj_stargate_ambientSound",
    tpArea = "kj_stargate_transferArea",
    colliderV = "kj_stargate_colliderVert",
    colliderH1 = "kj_stargate_colliderHori1",
    colliderH2 = "kj_stargate_colliderHori2",
    colliderD = "kj_stargate_colliderDiag",
}
local dhdName = "kj_dhd"
local sgOffset = {x = 0, y = 1.3}
local poo = {
    nauvis = 1,
    gleba = 5,
    aquilo = 2,
    vulcanus = 4,
    fulgora = 3,
}

local chevronChars = {}
for i = 0, (string.byte("S") - string.byte("A")) do
    table.insert(chevronChars, string.char(string.byte("A") + i))
    table.insert(chevronChars, string.char(string.byte("a") + i))
end
--at start check for existing char tables
--regen when not existing
--otherwise generate on surface generation


stargate = {
	Connect = function(thisGate, otherGate)
        if otherGate.destination ~= nil then --other gate has connection
            util.playSoundOnSurface(thisGate.entity.surface, thisGate.entity.position, "kj_stargate_fail")
        else
            if thisGate.destination ~= nil then
                thisGate:Disconnect()
            end
            activateGate(thisGate)
            activateGate(otherGate)
            thisGate.destination = otherGate
            otherGate.destination = thisGate

            storage.activeGates = storage.activeGates or {}
            table.insert(storage.activeGates, {tick = game.tick + 20*60, stargate = thisGate})

            thisGate.entity.minable = false
            otherGate.entity.minable = false
            game.print("Gates connected: "..thisGate.id.."|"..otherGate.id)
        end
	end,

    Disconnect = function(self)
        local dest = self.destination
        if dest then
            deactivateGate(self)
            deactivateGate(dest)

            self.entity.minable = true
            dest.entity.minable = true
            game.print("Gates disconnected: "..self.id.."|"..dest.id)
        end
    end,
}

dhd = {
    GetAddress = function(self)
        --local address = ""

        --for _, char in ipairs(self.address) do
        --    address = address..char
        --end
        
        --return address
        return table.concat(self.address)
    end,
	Connect = function(self)
        --if string exists, then connect, otherwise empty table and make fail sound
        local selfAddress = self:GetAddress()
        local result = false
        local surface
        for s, address in pairs(storage.addresses) do
            if selfAddress == address.."poo_"..poo[s] then
                surface = s
                result = true
            end
        end

        if result == true then
            game.print("omg we found a connection!")
            self.stargate:Connect(findRandomGateOnSurface(surface))
        else
            util.playSoundOnSurface(self.stargate.entity.surface, self.stargate.entity.position, "kj_stargate_fail")
            game.print("no gate with that address. emptying ram")
            self.stargate.chevrons.animation_offset = 0
        end
        self.address = {}
	end,

    Disconnect = function(self)
    end,
}

function findRandomGateOnSurface(surface)
    local gates = {}
    for _, gate in pairs(storage.stargate[surface]) do
        table.insert(gates, gate)
    end
    return gates[math.random(1, #gates)]
end

function deactivateGate(gate)
    gate.active = false
    gate.chevrons.animation_offset = 0
    gate.animation.destroy()
    gate.destination = nil
    util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_close")
end

function activateGate(gate)
    gate.active = true
    --[[gate.animation = rendering.draw_animation{
        animation = "kj_stargate_eventHorizon",
        target = util.vector2Add(gate.entity.position, {x = 0, y = -10.2}),--gate.childs.baseEnt,
        surface = gate.entity.surface,
        render_layer = "object",
        y_scale = 5,
    }]]
    gate.chevrons.animation_offset = 7
    gate.animation = gate.entity.surface.create_entity{
        name = "kj_stargate_eventHorizon_ent",
        position = util.vector2Add(gate.entity.position, {x = 0, y = -0.19}),
    }
    gate.animation.destructible = false
    util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_open")
end

function OnLoad(e)
	if storage.stargate then
		for _, surface in pairs(storage.stargate) do
            for _, gate in pairs(surface) do
                setmetatable(gate, {__index = stargate})
            end
		end
	end
	if storage.dhd then
		for _, surface in pairs(storage.dhd) do
            for _, device in pairs(surface) do
                setmetatable(device, {__index = dhd})
            end
		end
	end

	util.mtMgr.OnLoad()
end

function addAddressToGlobal(surface, address)
    if surface.platform ~= nil then return end
    storage.addresses = storage.addresses or {}
    storage.addresses[surface.name] = storage.addresses[surface.name] or address
end

function generateAdress(surface)
    --setting up rng
    local mapSeed = surface.map_gen_settings.seed
    local hash = util.hash_fnv1a(mapSeed..surface.name)
    local generator = game.create_random_generator(hash)
    game.print(surface.name.. " - Game Seed: "..mapSeed.." - Custom Seed: "..hash)

    local result = {}
    local used = {}

    for i = 1, 6 do
        local char
        repeat
            local index = generator(1, #chevronChars)
            char = chevronChars[index]
        until not used[char]

        result[i] = char
        used[char] = true
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

function GateTransit(gate, player, vehicle)
    local pos = util.vector2Add(gate.entity.position, sgOffset)
    util.playSoundOnSurface(player.surface, player.position, "kj_stargate_enter")
    player.teleport(
        pos,
        gate.entity.surface
    )
    if vehicle ~= nil then
        local speed = vehicle.speed
        vehicle.teleport(
            pos,
            gate.entity.surface
        )
        --flip car in certain value ranges
        vehicle.orientation = (vehicle.orientation < 0.25 or vehicle.orientation > 0.75) and 0.5 or 0
        vehicle.speed = speed
        vehicle.set_driver(player)

        local modus = (vehicle.orientation == 0) and defines.riding.acceleration.reversing or defines.riding.acceleration.accelerating
		player.riding_state = {acceleration = modus, direction = defines.riding.direction.straight}

        storage.vehicles = storage.vehicles or {}
        table.insert(storage.vehicles, {tick = game.tick + 5, vehicle = vehicle})

        storage.ignoredVehicles = storage.ignoredVehicles or {}
        storage.ignoredVehicles[vehicle.unit_number] = game.tick + 10
    else
        storage.players = storage.players or {}
        table.insert(storage.players, {tick = game.tick + 15, player = player})
    end
    util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_enter")
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
        local chevrons = rendering.draw_animation{
            animation = "kj_stargate_chevrons",
            target = util.vector2Add(pos, {x = 0, y = -2}),
            surface = surface,
            render_layer = "object",
            animation_speed = 0,
        }
        local childs = {
            baseEnt = surface.create_entity{
                name = sgNames.base,
                position = util.vector2Add(pos, {x = 0, y = -2}),
            },
            soundEnt = surface.create_entity{
                name = sgNames.sound,
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
        --childs.soundEnt.active = true
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
            chevrons = chevrons,
        }
        util.addToGlobal("stargate", tpArea, content)

        ent.destroy()
    elseif ent.name == dhdName then --dhd placed
        ent.destructible = false
        local content = {
            address = {}
        }
        util.addToGlobal("dhd", ent, content)
    end
end

function OnRemoved(e)
	local ent = e.entity
    if not ent.valid then return end

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
    local vehicle = player.vehicle
    if not storage.stargate[player.surface.name] then return end

    if vehicle and vehicle.prototype.type == "spider-vehicle" then return end

    local deleteGate = {}
    for gID, gate in pairs(storage.stargate[player.surface.name]) do
        if gate.valid == true and gate.entity and gate.entity.valid then
            if gate.active == true and gate.destination then
                if not vehicle then --player not in vehicle
                    if util.positionInBoundingBox(player.position, gate.entity.bounding_box) == true then
                        --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                        GateTransit(gate.destination, player, vehicle)
                    end
                else --player in vehicle
                    local iV = storage.ignoredVehicles and storage.ignoredVehicles[vehicle.unit_number]
                    if not iV or (iV and iV < game.tick) then
                        if util.rotatedBoxInsideBoundingBox(vehicle.bounding_box, vehicle.orientation, gate.entity.bounding_box) == true then
                            --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                            GateTransit(gate.destination, player, vehicle)
                            iV = nil
                        end
                    end
                end
            end
        else
            table.insert(deleteGate, gID)
        end
    end

    for _, k in ipairs(deleteGate) do
        storage.stargate[player.surface.name][k] = nil
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
    local players = storage.players
    local vehicles = storage.vehicles

    if players ~= nil then
        for i = #players, 1, -1 do
            local player = players[i]
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
    if vehicles ~= nil then
        for i = #vehicles, 1, -1 do
            local vehicle = vehicles[i]
            if vehicle.vehicle.valid then
                if game.tick > vehicle.tick then
                    local driver = vehicle.vehicle.get_driver()
                    if driver then
                        driver.riding_state = {acceleration = defines.riding.acceleration.nothing, direction = defines.riding.direction.straight}
                    end
                    table.remove(storage.vehicles, i)
                end
            else
                table.remove(storage.vehicles, i)
            end
        end
    end
end

function OnNthTickPlayer(e)
    if not storage.stargate then return end
    local deleteGate = {}
    for sgSurface, gates in pairs(storage.stargate) do
        for gID, gate in pairs(gates) do
            if gate.valid == true and gate.entity and gate.entity.valid then
                if gate.active == true and gate.destination then
                    for _, player in pairs(game.players) do
                        local vehicle = player.physical_vehicle
                        if player.surface.name == sgSurface and not (vehicle and vehicle.prototype.type == "spider-vehicle") then
                            if vehicle == nil then --player not in vehicle
                                if util.positionInBoundingBox(player.physical_position, gate.entity.bounding_box) == true then
                                    --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                                    GateTransit(gate.destination, player, vehicle)
                                end
                            else --player in vehicle
                                local iV = storage.ignoredVehicles and storage.ignoredVehicles[vehicle.unit_number]
                                if not iV or (iV and iV < game.tick) then
                                    if util.rotatedBoxInsideBoundingBox(vehicle.bounding_box, vehicle.orientation, gate.entity.bounding_box) == true then
                                        --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                                        GateTransit(gate.destination, player, vehicle)
                                        iV = nil
                                    end
                                end
                            end
                        end
                    end
                end
            else
                deleteGate.sgSurface = gID
            end
        end
    end

    for v, k in ipairs(deleteGate) do
        storage.stargate[v][k] = nil
    end

    --[[
    on player moved:
        check all gates
            check if players are inside border
                teleport if yes
                also teleport vehicle
    ]]
end

function OnNthTickGates(e)
    local gates = storage.activeGates
    if gates ~= nil then
        for i = #gates, 1, -1 do
            local gate = gates[i]
            if game.tick > gate.tick then
                gate.stargate:Disconnect()
                table.remove(storage.activeGates, i)
            end
        end
    end
end

function GuiOpened(e)
    --game.print("Gui opened")
    local player = game.players[e.player_index]

    if e.entity and e.entity.name == "kj_dhd" then
        game.print("DHD opened")
        local dhd, dhdID = util.findInGlobal("dhd", e.entity)
        if dhd == nil or dhd.stargate == nil then
            player.opened = nil
            return
        end

        gui = player.gui.screen.dhd
        local refs
        if not gui then
            gui, refs = glib.add(player.gui.screen, sg_guis.dhd_frame_new("dhd", {"dhd"}))
        else
            gui.visible = true
        end

        if refs.stargates then
            --AssembleGatesInDHDGUI(refs.stargates, e.entity.surface.name, dhdID)
            AssembleLettersInDHDGUI(refs.stargates, e.entity.surface.name, dhdID)
        end

        gui.force_auto_center()
        gui.bring_to_front()
        player.opened = gui
    end
end

function AssembleLettersInDHDGUI(root, dhdSurface, dhdID)
    glib.add(root, sg_guis.dhd_letter("poo_"..poo[dhdSurface], dhdSurface, dhdID))
    for _, char in ipairs(chevronChars) do
        glib.add(root, sg_guis.dhd_letter(char, dhdSurface, dhdID))
    end
    glib.add(root, sg_guis.dhd_letter("connect", dhdSurface, dhdID))
end

function AssembleGatesInDHDGUI(root, dhdSurface, dhdID)
    if storage.stargate == nil then return end
    glib.add(root, sg_guis.dhd_element("solar-system-edge", 0, dhdSurface, dhdID))
    for sName, gates in pairs(storage.stargate) do
        game.print("Gate order:")
        for sgID, _ in pairs(gates) do
            game.print(sgID)
            glib.add(root, sg_guis.dhd_element(sName, sgID, dhdSurface, dhdID))
        end
    end
end

--script.on_event(defines.events.on_player_changed_position, OnPlayerMoved)

script.on_event(defines.events.on_built_entity, OnBuilt)
script.on_event(defines.events.on_robot_built_entity, OnBuilt)

script.on_load(OnLoad)
--script.on_configuration_changed(OnConfigChanged)

script.on_event(defines.events.on_player_mined_entity, OnRemoved)
script.on_event(defines.events.on_robot_mined_entity, OnRemoved)
script.on_event(defines.events.on_entity_died, OnRemoved)

script.on_event(defines.events.on_tick, OnTick)
script.on_nth_tick(60, OnNthTickGates)
script.on_nth_tick(2, OnNthTickPlayer)

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