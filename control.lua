if script.active_mods["gvv"] then require("__gvv__.gvv")() end
util = require("utils")
require("util")
require("logic.gate")
sg_guis = require("logic.gui")
mod_gui = require("mod-gui")
glib = require("__glib__/glib")

if script.active_mods["kj_vehicles"] then
    kj_compat = require("__kj_vehicles__.utils")
end
--seed: 163867536
sgOffset = {x = 0, y = 1.3}
poo = {
    nauvis = 1,
    gleba = 5,
    aquilo = 2,
    vulcanus = 4,
    fulgora = 3,
}
sgNames = {
    placement = "kj_stargate_placement",
    placementSignaled = "kj_stargate_signaled_placement",
    base = "kj_stargate_base",
    sound = "kj_stargate_ambientSound",
    rings = "kj_stargate_ring",
    tpArea = "kj_stargate_transferArea",
    tpAreaSignaled = "kj_stargate_transferArea_signaled",
    colliderV = "kj_stargate_colliderVert",
    colliderHL = "kj_stargate_colliderHoriLong",
    colliderHLL = "kj_stargate_colliderHoriLonger",
    colliderHB = "kj_stargate_colliderHoriBig",
    colliderHS = "kj_stargate_colliderHoriShort",
    colliderD = "kj_stargate_colliderDiag",
}
dhdName = "kj_dhd"


function initStorage()
    local names = {
        dhd = true,
        stargate = true,
        tasks = true,
        addresses = true,
        ignoredVehicles = true, --vehicles that were just teleported are ignored for some ticks so they dont teleport constantly back and forth
        autoGenGates = true,
        illegalCars = true,
    }
    local tasks = {
        activeGates = true,
        busyDhds = true, -- tracks the resets of dhd after x time
        eventHorizons = true,
        vehicles = true,
        players = true,
        delayedSounds = true,
        delayedTurnOffs = true,
        signaledGates = true,
    }
    for name, _ in pairs(names) do
        storage[name] = storage[name] or {}
    end
    for task, _ in pairs(tasks) do
        storage.tasks[task] = storage.tasks[task] or {}
    end

    local cars = prototypes.get_entity_filtered({{filter = "type", type = "car"}})
    for name, car in pairs(cars) do
        local collBox = car.collision_box
        if math.abs(collBox.left_top.x) + math.abs(collBox.right_bottom.x) > 3 then
            storage.illegalCars[name] = true
        end
        game.print("saas")
    end
    if kj_compat and kj_compat.wideCars then
        for _, name in pairs(kj_compat.wideCars) do
            storage.illegalCars[name] = true
        end
    end
    storage.illegalCars["heli-entity-_-"] = true
    storage.illegalCars["scout-heli-entity-_-"] = true
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

function OnInit(e)
    initStorage()
    for _, surface in pairs(game.surfaces) do
        addAddressToGlobal(surface, generateAdress(surface))
        --[[Chunk({
            position = {x = 0, y = 0},
            surface = surface
        })]]
    end
end

function OnBuilt(e)
	local ent = e.entity
    if not ent.valid then return end
    --game.print("Placed "..ent.name)

	if ent.name == sgNames.placementSignaled then --signaled stargate placed
        local pos = ent.position
        local surface = ent.surface
        local tpArea = surface.create_entity{
            name = sgNames.tpAreaSignaled,
            force = "neutral",
            position = util.vector2Add(pos, {x = 0, y = -1.8}),
        }
        local chevrons = rendering.draw_animation{
            animation = "kj_stargate_chevrons_s",
            target = util.vector2Add(pos, {x = 0, y = -0.99}),
            surface = surface,
            render_layer = "object",
            animation_speed = 0,
        }
        local childs = {
            energyDrain = surface.create_entity{
                name = "kj_stargate_gate_s_energyDrain",
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = -8}),
            },

            colliderH11 = surface.create_entity{
                name = sgNames.colliderHL,
                position = util.vector2Add(pos, {x = 0, y = -2.275}),
            },
            colliderH12 = surface.create_entity{
                name = sgNames.colliderHL,
                position = util.vector2Add(pos, {x = 0, y = -2.275-0.75}),
            },

            colliderVB1 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = -2.75, y = -0.5}),
            },
            colliderVB2 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = 2.75, y = -0.5}),
            },
            colliderVB3 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = -1.75-0.025, y = -0.5}),
            },
            colliderVB4 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = 1.75+0.025, y = -0.5}),
            },

            colliderH21 = surface.create_entity{
                name = sgNames.colliderHB,
                position = util.vector2Add(pos, {x = -3.5, y = -1}),
            },
            colliderH22 = surface.create_entity{
                name = sgNames.colliderHB,
                position = util.vector2Add(pos, {x = 3.5, y = -1}),
            },

            colliderVL1 = surface.create_entity{
                name = sgNames.colliderHLL,
                position = util.vector2Add(pos, {x = -1.5, y = 1.5}),
                direction = defines.direction.east,
            },
            colliderVL2 = surface.create_entity{
                name = sgNames.colliderHLL,
                position = util.vector2Add(pos, {x = 1.5, y = 1.5}),
                direction = defines.direction.west,
            },

            rings = surface.create_entity{
                name = sgNames.rings,
                position = util.vector2Add(pos, {x = 0, y = -1.85}),
                force = "neutral",
            },
        }
        childs.energyDrain.power_usage = 10^7/60

        for _, child in pairs(childs) do
            child.destructible = false
        end

        childs.baseEnt = rendering.draw_sprite{
            sprite = "kj_stargate_base_sprite_s",
            target = util.vector2Add(pos, {x = 0, y = -1.9}),
            surface = surface,
            render_layer = "object",
        }
        childs.baseEntBckgrnd = rendering.draw_sprite{
            sprite = "kj_stargate_base_sprite_s_background",
            target = util.vector2Add(pos, {x = 0, y = -2.5}),
            surface = surface,
            render_layer = "object",
        }

        local calcPosis = {}
        for i = 1, -1, -2 do
            for y = -2, 5, 1 do
                table.insert(calcPosis, {position = util.vector2Add(pos, {-0.5 * i, y}), name = "kj_stargate_metalTile"})
            end
        end

        local oldTiles = {}
        for _, tile in pairs(calcPosis) do
            tile = surface.get_tile(tile.position.x, tile.position.y)
            table.insert(oldTiles, {name = tile.name, position = tile.position})
        end

        surface.set_tiles(calcPosis)

        local content = {
            destAddress = {},
            destAddressLetters = {},
            lastGlyph = "poo",

            manual = false,
            valid = true,
            active = false,
            childs = childs,
            oldTiles = oldTiles,
            destination = nil,
            chevrons = chevrons,
            safeToTravel = false,
        }
        util.addToGlobal("stargate", tpArea, content)

        ent.destroy()
    elseif ent.name == sgNames.placement then --manual stargate placed
        local pos = ent.position
        local surface = ent.surface
        local tpArea = surface.create_entity{
            name = sgNames.tpArea,
            force = "neutral",
            position = util.vector2Add(pos, {x = 0, y = -1.8}),
        }
        local chevrons = rendering.draw_animation{
            animation = "kj_stargate_chevrons",
            target = util.vector2Add(pos, {x = 0, y = -1.99}),
            surface = surface,
            render_layer = "object",
            animation_speed = 0,
        }
        local childs = {
            colliderV1 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = -3.5, y = -1}),
            },
            colliderV2 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = 3.5, y = -1}),
            },

            colliderH11 = surface.create_entity{
                name = sgNames.colliderHL,
                position = util.vector2Add(pos, {x = 0, y = -2.275}),
            },

            colliderH21 = surface.create_entity{
                name = sgNames.colliderHS,
                position = util.vector2Add(pos, {x = -2.5, y = -0.5}),
            },
            colliderH22 = surface.create_entity{
                name = sgNames.colliderHS,
                position = util.vector2Add(pos, {x = 2.5, y = -0.5}),
            },
            colliderH31 = surface.create_entity{
                name = sgNames.colliderHS,
                position = util.vector2Add(pos, {x = -2.25, y = -1.6}),
            },
            colliderH32 = surface.create_entity{
                name = sgNames.colliderHS,
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

        --tpArea.destructible = false
        for _, child in pairs(childs) do
            child.destructible = false
        end

        childs.baseEnt = rendering.draw_sprite{
            sprite = "kj_stargate_base_sprite",
            target = util.vector2Add(pos, {x = 0, y = -2}),
            surface = surface,
            render_layer = "object",
        }
        childs.baseEntBckgrnd = rendering.draw_sprite{
            sprite = "kj_stargate_base_sprite_background",
            target = util.vector2Add(pos, {x = 0, y = -2.5}),
            surface = surface,
            render_layer = "object",
        }

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
            manual = true,
            valid = true,
            active = false,
            childs = childs,
            oldTiles = oldTiles,
            destination = nil,
            chevrons = chevrons,
            safeToTravel = false,
        }
        util.addToGlobal("stargate", tpArea, content)

        ent.destroy()
    elseif ent.name == dhdName then --dhd placed
        ent.rotatable = false
        ent.force = "neutral"

        local glyphAnimation = {}
        for i = 1, 7, 1 do
            table.insert(glyphAnimation, rendering.draw_animation{
                animation = "kj_stargate_dhd_"..ent.direction,
                animation_speed = 0,
                target = ent.position,
                surface = ent.surface,
                render_layer = "object",
            })
        end

        local content = {
            address = {},
            addressLetters = {},
            glyphs = glyphAnimation
        }
        local dhd = util.addToGlobal("dhd", ent, content)
        if dhd.stargate then
            dhd:Initialize()
        end
    end
end

function OnRemoved(e)
	local ent = e.entity
    if not ent.valid then return end
    --game.print(ent.name.." destroyed")

	if ent.name == sgNames.tpArea or ent.name == sgNames.tpAreaSignaled then
        local sg = util.findInGlobal("stargate", ent)
        if sg.oldTiles then
            for i = #sg.oldTiles, 1, -1 do
                local tile = sg.oldTiles[i]
                if ent.surface.get_tile(tile.position.x, tile.position.y).name == "nuclear-ground" then
                    table.remove(sg.oldTiles, i)
                end
            end
            ent.surface.set_tiles(sg.oldTiles)
        end

        util.removeFromGlobal("stargate", ent)

    elseif ent.name == dhdName then
        local dhd, _ = util.findInGlobal("dhd", ent)
        if dhd and dhd.stargate then
            dhd:Connect("deineMom")
        end
        local stargate = util.removeFromGlobal("dhd", ent)

        if stargate ~= nil and stargate.active == true then --cutting connection ?
            --stargate.active = false
            --stargate.destination = nil
            --util.playSoundOnSurface(ent.surface, stargate.entity.position, "kj_stargate_close")
            --if stargate.animation then stargate.animation.destroy() end
        end
    end
end

function OnTick(e)
    local players = storage.tasks.players
    local vehicles = storage.tasks.vehicles
    local sounds = storage.tasks.delayedSounds
    local eventHorizons = storage.tasks.eventHorizons
    local delayedTurnOffs = storage.tasks.delayedTurnOffs

    if players ~= nil then
        for i = #players, 1, -1 do
            local player = players[i]
            if game.tick < player.tick then
                player.player.walking_state = {
                    walking = true,
                    direction = 8
                }
            else
                table.remove(storage.tasks.players, i)
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
                    table.remove(storage.tasks.vehicles, i)
                end
            else
                table.remove(storage.tasks.vehicles, i)
            end
        end
    end
    if sounds ~= nil then
        for i = #sounds, 1, -1 do
            local sound = sounds[i]
            if game.tick > sound.tick then
                util.playSoundOnSurface(sound.surface, sound.position, sound.sound)
                table.remove(storage.tasks.delayedSounds, i)
            end
        end
    end
    if eventHorizons ~= nil then
        for id, eH in pairs(eventHorizons) do
            if game.tick > eH.tick then
                local effectPos1 = util.vector2Add(eH.gate.entity.position, {x = 0, y = 2.5})
                local effectPos2 = util.vector2Add(eH.gate.entity.position, {x = 0, y = 5.5})

                eH.gate.animation = rendering.draw_animation{
                    animation = "kj_stargate_eventHorizon",
                    target = util.vector2Add(eH.gate.entity.position, {x = 0, y = (eH.gate.manual and -0.19 or -0.215)}),
                    surface = eH.gate.entity.surface,
                    render_layer = "object",
                }
                eH.gate.entity.surface.create_entity {
                    name = "kj_stargate_woosh_dmg",
                    position = effectPos1,
                    force = "enemy",
                    target = effectPos1,
                    speed = 1,
                }
                eH.gate.entity.surface.create_entity {
                    name = "kj_stargate_woosh_dmg",
                    position = effectPos2,
                    force = "enemy",
                    target = effectPos2,
                    speed = 1,
                }
                eH.gate.safeToTravel = true
                storage.tasks.eventHorizons[id] = nil
            end
        end
    end
    if delayedTurnOffs ~= nil then
        for id, dTO in pairs(delayedTurnOffs) do
            if game.tick > dTO.tick then
                dTO.gate.safeToTravel = false
                dTO.gate.destination = nil
                storage.tasks.delayedTurnOffs[id] = nil
            end
        end
    end
end

function OnNthTickPlayer(e)
    if not storage.stargate then return end
    local deleteGate = {}
    for _, player in pairs(game.players) do
        if not storage.stargate[player.surface.name] then return end

        for gID, gate in pairs(storage.stargate[player.surface.name]) do
            if gate.valid == true and gate.entity and gate.entity.valid then
                if gate.safeToTravel == true and gate.destination then
                    local vehicle = player.physical_vehicle
                    if (vehicle and vehicle.prototype.type == "spider-vehicle") then return end
                    if util.getDistance(player.physical_position, gate.entity.position) > 13 then return end

                    if vehicle == nil then --player not in vehicle
                        if player.character and util.boundingBoxesCollision(player.character.bounding_box, gate.entity.bounding_box) then
                            --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                            GateTransit(gate.destination, player, vehicle)
                        end
                    else --player in vehicle
                        if storage.illegalCars[vehicle.name] then return end
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
                deleteGate.sgSurface = gID
            end
        end
    end

    for v, k in ipairs(deleteGate) do
        storage.stargate[v][k] = nil
    end
end

function OnNthTickSGates(e)
    local signaledGates = storage.tasks.signaledGates
    if not signaledGates then return end

    --[[signaledGate = {
        gate = nil, --gate ref
        glyphs = {
            {letter = "a", tick = game.tick+60},
            {letter = "b", tick = game.tick+120},
        },
        pooID = "1"
    }]]
    for id, gate in pairs(signaledGates) do

        if #gate.glyphs > 0 then
            local glyph = gate.glyphs[1]
            if game.tick >= glyph.tick then

                    gate.gate.destAddressLetters = gate.gate.destAddressLetters or {}
                    gate.gate.destAddress = gate.gate.destAddress or {}

                gate.gate.destAddressLetters[glyph.letter] = true
                table.insert(gate.gate.destAddress, glyph.letter)
                table.remove(gate.glyphs, 1)


                local direction = (glyph.direction % 2) * 2 --(#gate.gate.destAddress % 2) * 2
                gate.gate.childs.rings.riding_state = {
                    acceleration = defines.riding.acceleration.nothing,
                    direction = direction,
                }

                gate.gate.chevrons.animation_offset = gate.gate.chevrons.animation_offset + 1
                util.playSoundOnSurface(gate.gate.entity.surface, gate.gate.entity.position, util.randomSound("kj_stargate_chevron", 3))
                --add the rotation shiz
            end
        else
            gate.gate.childs.rings.riding_state = {
                acceleration = defines.riding.acceleration.nothing,
                direction = defines.riding.direction.straight,
            }
            game.print("Address dialing: "..gate.gate:GetDestAddress())
            local success = false

            if gate.pooID == poo[gate.gate.entity.surface.name] then --is poo glyph correct one (momentarily obsolete though)
                for surf, address in pairs(storage.addresses) do
                    if surf ~= gate.gate.entity.surface.name then --not on same surface
                        if address.."poo" == gate.gate:GetDestAddress() then
                            game.print("Address found: "..surf)
                            if gate.gate:Connect(findRandomGateOnSurface(surf)) then
                                success = true
                            end
                        end
                    end
                end
            end

            gate.gate.childs.energyDrain.energy = 0
            gate.gate:ResetAddress()
            signaledGates[id] = nil

            if success == false then
                gate.gate.chevrons.animation_offset = 0
                util.playSoundOnSurface(gate.gate.entity.surface, gate.gate.entity.position, "kj_stargate_fail")
            else
                gate.gate.childs.energyDrain.electric_buffer_size = 10^7
            end
        end
    end
end

function OnNthTickGates(e)
    if not storage.stargate then return end
    local surfaces = storage.stargate

    for _, surface in pairs(surfaces) do
        for _, gate in pairs(surface) do
            if gate.manual == true then goto continue end
            if storage.tasks.signaledGates[gate.id] ~= nil then goto continue end
            local signals = gate.entity.get_signals(1)
            if signals == nil then goto continue end

            if gate.active == false then
                if gate.safeToTravel == false then
                    if gate.childs.energyDrain and gate.childs.energyDrain.energy ~= 10^9 then return end
                    local address = ""
                    local addressLetters = {}
                    local letterIndex = 1
                    local successful = false
                    local disConnect = 0
                    local tickOffset = 60
                    local pooGlyphID = ""
                    local surfaceName = gate.entity.surface.name

                    table.sort(signals, function(a, b) --sort ascending
                        return a.count < b.count
                    end)

                    for _, signal in ipairs(signals) do
                        local glyph = signal.signal.name:match("^kj_sg_glyph_(.+)$")

                        if charLookup[glyph] ~= nil then --signal is a glyph
                            if letterIndex == signal.count then --glyph has correct count
                                if glyph ~= "poo_"..poo[surfaceName] then --glyph is a letter, gets concat to address
                                    table.insert(addressLetters, glyph)
                                    address = address..glyph
                                else
                                    if letterIndex == 7 and tonumber(glyph:match("_(%d+)$")) == poo[surfaceName] then --is poo glyph same as surface
                                        pooGlyphID = poo[surfaceName]
                                        table.insert(addressLetters, "poo")
                                        successful = true
                                    end
                                end

                                letterIndex = letterIndex + 1
                            else
                                break --letter sequence broken, abort
                            end
                        else
                            if glyph == "connect" then --signal is connection command
                                if signal.count == 1 then
                                    disConnect = 1
                                else
                                    disConnect = -1
                                    break
                                end
                            end
                        end
                    end

                    if successful == true and disConnect == 1 then
                        --for surf, ads in pairs(storage.addresses) do
                            --if surf ~= surfaceName then
                                --if ads == address then
                                    local task = {gate = gate, glyphs = {}, pooID = pooGlyphID}
                                    local prevLetter = gate.lastGlyph or "poo"
                                    local offset = 0

                                    for _, letter in ipairs(addressLetters) do
                                        local distance, dir = util.getRingGlyphDistance(prevLetter, letter)
                                        --game.print("Distance: "..prevLetter.." "..letter.." "..ringGlyphDistances[prevLetter][letter])
                                        game.print("Distance: "..prevLetter.." "..letter.." "..distance)
                                        game.print("Time: "..offset)
                                        game.print("Tick: "..game.tick + offset)
                                        --offset = offset + 3*60*(ringGlyphDistances[prevLetter][letter] / 19)
                                        offset = offset + 3*60*(distance / 19)
                                        table.insert(task.glyphs, {
                                            letter = letter, tick = game.tick + offset, direction = dir
                                        })
                                        prevLetter = letter
                                    end
                                    storage.tasks.signaledGates[gate.id] = task
                                    --game.print("Address found: "..surf)
                                    --gate:Connect(findRandomGateOnSurface(surf))
                                    --gate.childs.energyDrain.energy = 0
                                    --gate.childs.energyDrain.electric_buffer_size = 10^7
                                --end
                            --end
                        --end
                    end
                    game.print("Address entered: "..address)
                end
            else
                table.sort(signals, function(a, b) --sort ascending
                    return a.count < b.count
                end)

                for _, signal in ipairs(signals) do
                    if signal.count == -1 then
                        if signal.signal.name:match("^kj_sg_glyph_(.+)$") == "connect" then --signal is connection command
                            gate:Disconnect()
                            break
                        end
                    end
                end
            end
            ::continue::
        end
    end
end

function OnNthTickTasks(e)
    local gates = storage.tasks.activeGates
    local dhds = storage.tasks.busyDhds
    local deleteGate = {}
    local deleteDhd = {}

    if gates ~= nil then
        for id, gate in pairs(gates) do
            if game.tick > gate.tick then
                gate.stargate:Disconnect()
                table.insert(deleteGate, id)
            end
        end
    end
    for _, k in ipairs(deleteGate) do
        storage.tasks.activeGates[k] = nil
    end

    if dhds ~= nil then
        for id, dhd in pairs(dhds) do
            if game.tick > dhd.tick then
                dhd.dhd:Connect("deineMom")
                table.insert(deleteDhd, id)
            end
        end
    end
    for _, k in ipairs(deleteDhd) do
        storage.tasks.busyDhds[k] = nil
    end
end

function GuiOpened(e)
    local player = game.players[e.player_index]

    if e.entity and e.entity.name == dhdName then
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

        if refs.glyphs then
            AssembleLettersInDHDGUI(refs.glyphs, e.entity.surface.name, dhd)
        end

        gui.force_auto_center()
        gui.bring_to_front()
        player.opened = gui
    end

    if e.entity and e.entity.name == sgNames.tpAreaSignaled then
        player.opened = nil
    end
end

function OnDamaged(e)
    local entity = e.entity
    local type = e.damage_type.name
    local entityName = {
        kj_dhd = "dhd",
        kj_stargate_transferArea = "stargate",
        kj_stargate_transferArea_signaled = "stargate"
    }
    if type ~= "explosion" and type ~= "physical" then return end
    if (entityName[entity.name] ~= nil) and e.source and e.source.name == "kj_woosh_cloud" then
        entity.health = entity.max_health
        return
    end

    local remnant = {
        kj_dhd = "medium-small-remnants",
        kj_stargate_transferArea = "medium-remnants"
    }

    entity.health = math.floor(e.final_health + 0.5)
    if entity.health <= 0.1 then
        if string.sub(entity.name, -8) ~= "auto_gen" then
            local obj, _ = util.findInGlobal(entityName[entity.name], entity)
            if entityName[entity.name] == "stargate" then
                obj:Disconnect(true)
            end

            if type == "explosion" then --spawn a burried variant below
                local ent = entity.surface.create_entity{
                    name = "kj_"..entityName[entity.name].."_auto_gen",
                    position = entity.position,
                    force = "neutral",
                }
                --ent.destructible = false
                ent.graphics_variation = math.random(1,4)
            else --physical damage overload is supposed to destroy the gate
                entity.surface.create_entity{
                    name = remnant[entity.name],
                    position = entity.position,
                }
            end
        end
    end
end

function Chunk(e)
    local position = e.position
    local surface = e.surface
    if surface.platform ~= nil then return end

    if position.x == 0 and position.y == 0 then
        if not storage.autoGenGates[surface.name] then
            storage.autoGenGates[surface.name] = true
        else
            return
        end

        local pos
        local i = 0
        repeat
            i = i + 1
            pos = {math.random(-100,100), math.random(-100,100)}
            pos = surface.find_non_colliding_position("kj_stargate_auto_gen", pos, 5, 1, false)
        until pos ~= nil or i == 20

        if pos == nil then
            pos = surface.find_non_colliding_position("kj_stargate_auto_gen", {0,0}, 1000, 1, false)
        end

        if pos ~= nil then
            local ent = surface.create_entity{
                name = "kj_stargate_auto_gen",
                position = pos,
                force = "neutral",
            }
            ent.graphics_variation = math.random(1,4)
            --ent.destructible = false
            ent = surface.create_entity{
                name = "kj_dhd_auto_gen",
                position = pos,
                force = "neutral",
            }
            ent.graphics_variation = math.random(1,4)
            --ent.destructible = false
            game.print("Placed stargate and dhd at [gps="..pos.x..","..pos.y..","..surface.name.."]. Needed "..i.." attempts.")
        else
            game.print("Couldn't place stargate and dhd on "..surface.name.."! Starting area too crowded.")
        end
    end
end

script.on_event(defines.events.on_built_entity, OnBuilt)
script.on_event(defines.events.on_robot_built_entity, OnBuilt)

script.on_load(OnLoad)
script.on_configuration_changed(initStorage)

script.on_event(defines.events.on_player_mined_entity, OnRemoved)
script.on_event(defines.events.on_robot_mined_entity, OnRemoved)
script.on_event(defines.events.on_entity_died, OnRemoved)

script.on_event(defines.events.on_entity_damaged , OnDamaged, {
    {filter = "name", name = "kj_stargate_transferArea"},
    {filter = "name", name = "kj_stargate_transferArea_signaled", mode = "or"},
    {filter = "name", name = "kj_dhd", mode = "or"},
    {filter = "name", name = "kj_stargate_auto_gen", mode = "or"},
    {filter = "name", name = "kj_dhd_auto_gen", mode = "or"},
})

script.on_event(defines.events.on_tick, OnTick)
script.on_nth_tick(60, OnNthTickTasks)
script.on_nth_tick(10, OnNthTickGates)
script.on_nth_tick(6, OnNthTickSGates)
script.on_nth_tick(2, OnNthTickPlayer)

script.on_event(defines.events.on_surface_created,
    function(event)
        local surface = game.surfaces[event.surface_index]
        addAddressToGlobal(surface, generateAdress(surface))
    end
)

script.on_event(defines.events.on_gui_opened, GuiOpened)
script.on_event(defines.events.on_chunk_generated, Chunk)

script.on_init(OnInit)
