function LuaShortCut(e)
    local name

    if e.prototype_name then
        name = e.prototype_name
    elseif e.input_name then
        name = e.input_name
    end

    if name == "kj_stargate_gdo" then
        GUI.GDOTriggered(e)
    elseif name == "kj_stargate_addressBook" then
        GUI.AddressBookTriggered(e)
    end
end

function OnCorpsed(e)
    if #storage.corpses == 0 then return end
	--game.print("corpsed")
    if settings.global["kj_stargate_realistic_death"].value == true then
        for _, corpse in pairs(storage.corpses) do
            if e.tick == corpse.tick and e.prototype.name == corpse.name then
                for _, corpseEntity in pairs(e.corpses) do
                    corpseEntity.destroy()
                end
            end
        end
    end
end

function OnBuilt(e)
	local ent = e.entity
    if not ent.valid then return end
    --game.print("Placed "..ent.name)

	if ent.name == SGNAMES.placementSignaled or ent.name == SGNAMES.placementSignaledIris then --signaled stargate placed / iris
        local iris = false
        local pos = ent.position
        local surface = ent.surface
        if ent.name == SGNAMES.placementSignaledIris then
            iris = true
        end
        local entity = surface.create_entity{
            name = SGNAMES.entitySignaled,
            force = "neutral",
            position = util.vector2Add(pos, {x = 0, y = entOffY.entS}),
        }
        local chevrons = rendering.draw_animation{
            animation = "kj_stargate_chevrons_s",
            target = util.vector2Add(pos, {x = 0, y = -0.99}),
            surface = surface,
            render_layer = "object",
            animation_speed = 0,
        }
        local childs = {
            tpArea = surface.create_entity{
                name = SGNAMES.tpArea,
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = -1.8}),
            },

            signalReceiver = surface.create_entity{
                name = "kj_stargate_signal_receiver",
                force = "neutral",
                position = util.vector2Add(pos, {x = -1.5, y = 0}),
            },
            signalSender = surface.create_entity{
                name = "kj_stargate_signal_receiver",
                force = "neutral",
                position = util.vector2Add(pos, {x = 1.5, y = 0}),
            },

            colliderH11 = surface.create_entity{
                name = SGNAMES.colliderHL,
                position = util.vector2Add(pos, {x = 0, y = -2.275}),
                force = "neutral",
            },
            colliderH12 = surface.create_entity{
                name = SGNAMES.colliderHL,
                position = util.vector2Add(pos, {x = 0, y = -2.275-0.75}),
                force = "neutral",
            },

            colliderVB1 = surface.create_entity{
                name = SGNAMES.colliderV,
                position = util.vector2Add(pos, {x = -2.75, y = -0.5}),
                force = "neutral",
            },
            colliderVB2 = surface.create_entity{
                name = SGNAMES.colliderV,
                position = util.vector2Add(pos, {x = 2.75, y = -0.5}),
                force = "neutral",
            },
            colliderVB3 = surface.create_entity{
                name = SGNAMES.colliderV,
                position = util.vector2Add(pos, {x = -1.75-0.025, y = -0.5}),
                force = "neutral",
            },
            colliderVB4 = surface.create_entity{
                name = SGNAMES.colliderV,
                position = util.vector2Add(pos, {x = 1.75+0.025, y = -0.5}),
                force = "neutral",
            },

            colliderH21 = surface.create_entity{
                name = SGNAMES.colliderHB,
                position = util.vector2Add(pos, {x = -3.5, y = -1}),
                force = "neutral",
            },
            colliderH22 = surface.create_entity{
                name = SGNAMES.colliderHB,
                position = util.vector2Add(pos, {x = 3.5, y = -1}),
                force = "neutral",
            },

            colliderVL1 = surface.create_entity{
                name = SGNAMES.colliderHLL,
                position = util.vector2Add(pos, {x = -1.5, y = 1.5}),
                direction = defines.direction.east,
                force = "neutral",
            },
            colliderVL2 = surface.create_entity{
                name = SGNAMES.colliderHLL,
                position = util.vector2Add(pos, {x = 1.5, y = 1.5}),
                direction = defines.direction.west,
                force = "neutral",
            },

            rings = surface.create_entity{
                name = SGNAMES.rings,
                position = util.vector2Add(pos, {x = 0, y = -1.85}),
                force = "neutral",
            },

            lights = surface.create_entity{
                name = SGNAMES.lights,
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = 0}),
            },

            poleVisibleMiddle = surface.create_entity{
                name = SGNAMES.pole.."invisible",
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = -1}),
            },

            ringSound = surface.create_entity{
                name = SGNAMES.ringSound,
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = 3}),
            },
        }
        if iris == true then
            childs.iris = surface.create_entity{
                name = SGNAMES.iris,
                force = game.players[e.player_index].force,
                position = util.vector2Add(pos, {x = 0, y = -2}),
            }
            childs.iris.minable_flag = false
        end
        for _, child in pairs(childs) do
            child.destructible = false
        end

        entity.power_usage = 10^8/60
        entity.electric_interface_mode = defines.electric_interface_mode.tertiary_input

        childs.poleVisibleRight = surface.create_entity{
            name = SGNAMES.pole.."visible_right",
            force = "neutral",
            position = util.vector2Add(pos, {x = 4.7, y = -0.528}),
        }
        childs.poleVisibleLeft = surface.create_entity{
            name = SGNAMES.pole.."visible_left",
            force = "neutral",
            position = util.vector2Add(pos, {x =-4.7, y = -0.527}),
        }
        storage.electricPoles[childs.poleVisibleRight.unit_number] = entity.unit_number
        storage.electricPoles[childs.poleVisibleLeft.unit_number] = entity.unit_number

        childs.baseEnt = rendering.draw_sprite{
            sprite = "kj_stargate_base_sprite_s",
            target = util.vector2Add(pos, {x = 0, y = entOffY.base}),
            surface = surface,
            render_layer = "object",
        }
        childs.baseEntBckgrnd = rendering.draw_sprite{
            sprite = "kj_stargate_base_sprite_s_background",
            target = util.vector2Add(pos, {x = 0, y = entOffY.baseBck}),
            surface = surface,
            render_layer = "object",
        }
        local smokes = {}
        smokes.smokeL1 = rendering.draw_animation{
            animation = "kj_stargate_s_smoke",
            target = util.vector2Add(pos, {x = -2.3, y = -4}),
            surface = surface,
            render_layer = "cargo-hatch",
            orientation = 0.3,
            animation_speed = 1.033,
            visible = false,
        }
        smokes.smokeR1 = rendering.draw_animation{
            animation = "kj_stargate_s_smoke",
            target = util.vector2Add(pos, {x = 2.5, y = -3.8}),
            surface = surface,
            render_layer = "cargo-hatch",
            orientation = 0.6,
            animation_speed = 0.966,
            visible = false,
        }
        smokes.smokeL2 = rendering.draw_animation{
            animation = "kj_stargate_s_smoke",
            target = util.vector2Add(pos, {x = -3.4, y = -2.3}),
            surface = surface,
            render_layer = "cargo-hatch",
            orientation = 0.1,
            animation_speed = 0.86,
            x_scale = 1.3,
            y_scale = 1.3,
            tint = {1,1,1,0.4},
            visible = false,
        }
        smokes.smokeR2 = rendering.draw_animation{
            animation = "kj_stargate_s_smoke",
            target = util.vector2Add(pos, {x = 3.15, y = -2.15}),
            surface = surface,
            render_layer = "cargo-hatch",
            orientation = 0.8,
            animation_speed = 0.75,
            x_scale = 1.5,
            y_scale = 1.5,
            tint = {1,1,1,0.3},
            visible = false,
        }

        --[[y+0.5 always
        metal tile:
            x:-1to+1 y: -2to+5
        concrete:
            x:-2/+2  y: -3to+5
            x:-3/+3  y: -3to+1
            x:-1to+1 y: -3
            x:-4/+4  y: -1
            x:-5/+5  y: -1
        ]]
        local oldTiles = {}
        local metalConcretePos = {}
        for x = -1, 1, 1 do
            for y = -2, 5, 1 do
                local pos = util.vector2Add(pos, {x, 0.5 + y})
                table.insert(metalConcretePos, {position = pos, name = "kj_stargate_metalTile"})
                table.insert(oldTiles, {position = pos, name = "refined-concrete"})
            end
        end
        local concretePos = {}
        for x = -2, 2, 4 do
            for y = -3, 5, 1 do
                table.insert(concretePos, {position = util.vector2Add(pos, {x, 0.5 + y}), name = "refined-concrete"})
            end
        end
        for x = -3, 3, 6 do
            for y = -3, 1, 1 do
                table.insert(concretePos, {position = util.vector2Add(pos, {x, 0.5 + y}), name = "refined-concrete"})
            end
        end
        for x = -1, 1, 1 do
            table.insert(concretePos, {position = util.vector2Add(pos, {x, 0.5 -3}), name = "refined-concrete"})
        end
        for x = -4, 4, 8 do
            table.insert(concretePos, {position = util.vector2Add(pos, {x, 0.5 -1}), name = "refined-concrete"})
        end
        for x = -5, 5, 10 do
            table.insert(concretePos, {position = util.vector2Add(pos, {x, 0.5 -1}), name = "refined-concrete"})
        end

        for _, tile in pairs(metalConcretePos) do
            tile = surface.get_tile(tile.position.x, tile.position.y)
            table.insert(oldTiles, {name = tile.name, position = tile.position})
        end
        surface.set_tiles(metalConcretePos)
        surface.set_tiles(concretePos)

        local wireConsR = childs.poleVisibleRight.get_wire_connectors(true)
        local wireConsL = childs.poleVisibleLeft.get_wire_connectors(true)
        local wireConsM = childs.poleVisibleMiddle.get_wire_connectors(true)
        local wireConsSR = childs.signalReceiver.get_wire_connector(1, true)
        local wireConsSS = childs.signalSender.get_wire_connector(2, true)
        if iris == true then
            wireConsIR = childs.iris.get_wire_connector(2, true)
            wireConsR[2].connect_to(wireConsIR)
        end

        for id, wireConnector in pairs(wireConsM) do
            if wireConsL[id] then
                wireConnector.connect_to(wireConsL[id], false, defines.wire_origin.script)
            end
            if wireConsR[id] then
                wireConnector.connect_to(wireConsR[id], false, defines.wire_origin.script)
            end
        end
        wireConsM[1].connect_to(wireConsSR)
        wireConsM[2].connect_to(wireConsSS)
        --TODO either make quality fixed requisite or make this feature optional

        local content = {
            destAddress = {},
            destAddressLetters = {},
            recentAddresses = {},
            gdos = {["123456"] = true, ABCDEF = true},
            lastGlyph = "poo",

            manual = false,
            valid = true,
            active = false,
            childs = childs,
            smokes = smokes,
            oldTiles = oldTiles,
            destination = nil,
            chevrons = chevrons,
            safeToTravel = false,
            detailedCheckup = false,
            travelDirection = "",
        }
        local obj = util.addToGlobal("stargate", entity, content, true)
        if iris == true then
            storage.irisedGates[childs.iris.unit_number] = obj
        end

        ent.destroy()
    elseif ent.name == SGNAMES.placement then --manual stargate placed
        local pos = ent.position
        local surface = ent.surface
        local entity = surface.create_entity{
            name = SGNAMES.entity,
            force = "neutral",
            position = util.vector2Add(pos, {x = 0, y = entOffY.ent}),
        }
        local chevrons = rendering.draw_animation{
            animation = "kj_stargate_chevrons",
            target = util.vector2Add(pos, {x = 0, y = -1.99}),
            surface = surface,
            render_layer = "object",
            animation_speed = 0,
        }
        local childs = {
            tpArea = surface.create_entity{
                name = SGNAMES.tpArea,
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = -1.8}),
            },

            colliderV1 = surface.create_entity{
                name = SGNAMES.colliderV,
                position = util.vector2Add(pos, {x = -3.5, y = -1}),
            },
            colliderV2 = surface.create_entity{
                name = SGNAMES.colliderV,
                position = util.vector2Add(pos, {x = 3.5, y = -1}),
            },

            colliderH11 = surface.create_entity{
                name = SGNAMES.colliderHL,
                position = util.vector2Add(pos, {x = 0, y = -2.275}),
            },

            colliderH21 = surface.create_entity{
                name = SGNAMES.colliderHS,
                position = util.vector2Add(pos, {x = -2.5, y = -0.5}),
            },
            colliderH22 = surface.create_entity{
                name = SGNAMES.colliderHS,
                position = util.vector2Add(pos, {x = 2.5, y = -0.5}),
            },
            colliderH23 = surface.create_entity{
                name = SGNAMES.colliderHS,
                position = util.vector2Add(pos, {x = -3, y = 0}),
            },
            colliderH24 = surface.create_entity{
                name = SGNAMES.colliderHS,
                position = util.vector2Add(pos, {x = 3, y = 0}),
            },
            colliderH31 = surface.create_entity{
                name = SGNAMES.colliderHS,
                position = util.vector2Add(pos, {x = -2.25, y = -1.6}),
            },
            colliderH32 = surface.create_entity{
                name = SGNAMES.colliderHS,
                position = util.vector2Add(pos, {x = 2.25, y = -1.6}),
            },

            colliderD1 = surface.create_entity{
                name = SGNAMES.colliderD,
                position = util.vector2Add(pos, {x = -2.366, y = 0.225}),
                direction = defines.direction.southeast,
            },
            colliderD2 = surface.create_entity{
                name = SGNAMES.colliderD,
                position = util.vector2Add(pos, {x = 2.366, y = 0.225}),
                direction = defines.direction.southwest,
            },
        }

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
            detailedCheckup = true,
            travelDirection = "",
        }
        util.addToGlobal("stargate", entity, content)

        ent.destroy()
    elseif ent.name == SGNAMES.dhdName then --dhd placed
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

	if ent.name == SGNAMES.entity or ent.name == SGNAMES.entitySignaled then
        local gate = util.findInGlobal("stargate", ent)
        if gate and gate.oldTiles then
            for i = #gate.oldTiles, 1, -1 do
                local tile = gate.oldTiles[i]
                if ent.surface.get_tile(tile.position.x, tile.position.y).name == "nuclear-ground" then
                    table.remove(gate.oldTiles, i)
                end
            end
            ent.surface.set_tiles(gate.oldTiles)
            for _, tile in ipairs(gate.oldTiles) do
                tile.name = "refined-concrete"
            end
            ent.surface.set_tiles(gate.oldTiles)
        end

        if gate.childs.iris then
            --[[local player = game.players[e.player_index]
            if player and player.valid then
                player.insert({name = SGNAMES.iris, count = 1})
            end]]
            --TODO place iris item on the ground IF gate is not being fully destroyed by damage
        end
        util.removeFromGlobal("stargate", ent)

    elseif ent.name == SGNAMES.dhdName then
        local dhd, _ = util.findInGlobal("dhd", ent)
        if dhd and dhd.stargate then
            dhd:Connect("deineMom")
        end
        local stargate = util.removeFromGlobal("dhd", ent)

        if stargate ~= nil and stargate.active == true then --cutting connection ?
            --stargate.active = false
            --stargate.destination = nil
            --util.playSoundOnSurface(ent.surface, stargate.pos, "kj_stargate_close")
            --if stargate.animation then stargate.animation.destroy() end
        end
    elseif ent.name == skyNames.observatory then
        Sky.OnObservatoryRemoved(ent)
    elseif e.cause and e.cause.name == SGNAMES.iris then
        if settings.global["kj_stargate_realistic_death"].value == true then
            table.insert(storage.corpses, {tick = e.tick, name = ent.name})
        end
    end
end

function GuiOpened(e)
    local player = game.players[e.player_index]
    if not e.entity then return end
    local ent = e.entity

    if ent.name == SGNAMES.dhdName then
        GUI.DHD({
            entity = ent,
            player_index = e.player_index,
        })

    elseif ent.name == SGNAMES.entitySignaled then
        player.opened = nil

    elseif ent.name == skyNames.observatory then
        player.opened = nil
        local surface = game.surfaces[ent.surface_index]

        if ent.surface_index == player.physical_surface_index and util.getDistance(ent.position, player.physical_position) < 7
            --[[and ent.energy >= 10^7]] then--TODO remove comment
            if not settings.global["kj_stargate_observatory_night"].value
                or surface.daytime > surface.evening and surface.daytime < surface.morning
                or surface.freeze_daytime
                or surface.always_day then

                Sky.enter(player, ent)
            else
                player.print({"observatoryAtNight"})
            end
        end

    elseif ent.name == skyNames.star then
        player.opened = nil

    elseif ent.type == "power-switch" then
        GUI.GDOIris({
            name = ent.name,
            player_index = e.player_index,
            unit_number = ent.unit_number,
        })
    end
end

function OnDamaged(e)
    local entity = e.entity
    if not entity or entity and not entity.valid then return end
    if onDamagedEntities[entity.name] ~= nil then --managing (final) destruction of gate entities 
        local type = e.damage_type.name
        local entityName = {
            kj_dhd = "dhd",
            kj_stargate_entity = "stargate",
            kj_stargate_entity_signaled = "stargate",

            kj_dhd_auto_gen = "stargate",
            kj_stargate_auto_gen = "stargate",
        }
        if type ~= "explosion" and type ~= "physical" then return end
        if (entityName[entity.name] ~= nil) and e.source and e.source.name == "kj_woosh_cloud" then
            entity.health = entity.max_health
            return
        end

        local remnant = {
            kj_dhd = "medium-small-remnants",
            kj_stargate_entity = "medium-remnants",
            kj_stargate_entity_signaled = "big-remnants"
        }

        entity.health = math.floor(e.final_health + 0.5)
        if entity.health <= 0.1 then
            if string.sub(entity.name, -8) ~= "auto_gen" then
                if string.sub(entity.name, 1, 24) == "kj_stargate_pole_visible" then
                    util.findIDInGlobal("stargate",
                        entity.surface.name,
                        storage.electricPoles[entity.unit_number]
                    ).entity.damage(100000, "neutral", type)
                else
                    local obj, _ = util.findInGlobal(entityName[entity.name], entity)
                    if entityName[entity.name] == "stargate" then
                        obj:Disconnect(true)
                    end

                    if type == "explosion" then --spawn a burried variant below
                        local ent = entity.surface.create_entity{
                            name = "kj_"..entityName[entity.name].."_auto_gen",
                            position = obj.pos,
                            force = "neutral",
                        }
                        ent.graphics_variation = math.random(1,4)
                    else --physical damage overload is supposed to destroy the gate
                        entity.surface.create_entity{
                            name = remnant[entity.name],
                            position = obj.pos,
                        }
                    end
                end
            end
        end
    else --managing permanent death by woosh cloud
        if e.source and e.source.name == "kj_woosh_cloud" and entity.health <= 0 then
            if settings.global["kj_stargate_realistic_death"].value == true then
                table.insert(storage.corpses, {tick = e.tick, name = entity.name})
            end
        end
    end
end

function OnPlayerDied(e)
    Sky.OnPlayerGone(e)
    local player = game.players[e.player_index]
    local gui = player.gui.screen.gdo
    if gui then
        player.gui.screen.gdo.destroy()
        player.opened = nil
    end
end

function OnPlayerEnteredVehicle(e)
    local ent = e.entity
    if ent.name == "kj_stargate_ring" then
        if ent.get_driver() then
            ent.set_driver(nil)
        end
        if ent.get_passenger() then
            ent.set_passenger(nil)
        end
    end
end

function OnPlayerChangedPos(e)
    local player = game.players[e.player_index]
    local gui = player.gui.screen.gdo
    if gui then
        GUI.GDOTriggered({
            prototype_name = "kj_stargate_gdo",
            player_index = e.player_index,
        })
    end
end

function OnPlayerChangedForce(e)
    local gui = game.players[e.player_index].gui.screen.addBk
    if gui then
        gui.destroy()
    end
end

function Chunk(e)
    if util.isSkySurface(e.surface) then
        Sky.OnChunkGenerated(e)
    else
        local position = e.position
        local surface = e.surface
        if surface.platform ~= nil then return end
        if util.isSkySurface(surface) then return end

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
                ent = surface.create_entity{
                    name = "kj_dhd_auto_gen",
                    position = pos,
                    force = "neutral",
                }
                ent.graphics_variation = math.random(1,4)
                game.print("Placed stargate and dhd at [gps="..pos.x..","..pos.y..","..surface.name.."]. Needed "..i.." attempts.")
            else
                game.print("Couldn't place stargate and dhd on "..surface.name.."! Starting area too crowded.")
            end
        end
    end
end

function OnSurfaceCreated(e)
    local surface = game.surfaces[e.surface_index]
    if util.isSkySurface(surface) then return end
    Address.addAddressToGlobal(surface, Address.generateAddress(surface))

    for _, force in pairs(game.forces) do
        util.forceSurfaceSetup(force, surface)
        GUI.RefreshAllAddBks(force.name, surface)
    end
end

function OnForceCreated(e)
    Sky.OnForceCreated(e)
    local force = e.force

    for _, surface in pairs(game.surfaces) do
        util.forceSurfaceSetup(force, surface)
    end
end

function OnForceMerged(e)
    Sky.onForcesMerged(e)
    storage.addressBook[e.source_name] = nil
end

function OnPlayerChangedSurface(e)
    Sky.OnPlayerChangedSurface(e)
    if not e.surface_index then return end
    local player = game.players[e.player_index]
    util.forceSurfaceSetup(player.force, player.surface)
end
