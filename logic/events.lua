function OnBuilt(e)
	local ent = e.entity
    if not ent.valid then return end
    --game.print("Placed "..ent.name)

	if ent.name == sgNames.placementSignaled then --signaled stargate placed
        local pos = ent.position
        local surface = ent.surface
        local entity = surface.create_entity{
            name = sgNames.entitySignaled,
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
            tpArea = surface.create_entity{
                name = sgNames.tpArea,
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = -1.8}),
            },

            signalReceiver = surface.create_entity{
                name = "kj_stargate_signal_receiver",
                force = "neutral",
                position = util.vector2Add(pos, {x = -0.5, y = 0}),
            },
            signalSender = surface.create_entity{
                name = "kj_stargate_signal_receiver",
                force = "neutral",
                position = util.vector2Add(pos, {x = 0.5, y = 0}),
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

            lights = surface.create_entity{
                name = sgNames.lights,
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = 0}),
            },

            poleVisibleMiddle = surface.create_entity{
                name = sgNames.pole.."invisible",
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = -0.9}),
            },
        }
        for _, child in pairs(childs) do
            child.destructible = false
        end

        entity.power_usage = 10^7/60

        childs.poleVisibleRight = surface.create_entity{
            name = sgNames.pole.."visible_right",
            force = "neutral",
            position = util.vector2Add(pos, {x = 4.7, y = -0.528}),
        }
        childs.poleVisibleLeft = surface.create_entity{
            name = sgNames.pole.."visible_left",
            force = "neutral",
            position = util.vector2Add(pos, {x =-4.7, y = -0.527}),
        }
        storage.electricPoles[childs.poleVisibleRight.unit_number] = entity.unit_number
        storage.electricPoles[childs.poleVisibleLeft.unit_number] = entity.unit_number

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

        local wireConsR = childs.poleVisibleRight.get_wire_connectors(true)
        local wireConsL = childs.poleVisibleLeft.get_wire_connectors(true)
        local wireConsM = childs.poleVisibleMiddle.get_wire_connectors(true)
        local wireConsSR = childs.signalReceiver.get_wire_connector(1, true)
        local wireConsSS = childs.signalSender.get_wire_connector(2, true)

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
        --local cb = childs.signalSender.get_or_create_control_behavior()
        --TODO either make quality fixed requisite or make this feature optional
        --cb.add_section()--this address state
        --cb.add_section()--this address (common quality)
        --cb.add_section()--previous address (uncommon quality)
        --cb.add_section()--previous x2 address (rare quality)
        --cb.add_section()--previous x3 address (epic quality)
        --cb.add_section()--previous x4 address (legendary quality)

        local content = {
            destAddress = {},
            destAddressLetters = {},
            recentAddresses = {},
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
        util.addToGlobal("stargate", entity, content, true)

        ent.destroy()
    elseif ent.name == sgNames.placement then --manual stargate placed
        local pos = ent.position
        local surface = ent.surface
        local entity = surface.create_entity{
            name = sgNames.entity,
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
            tpArea = surface.create_entity{
                name = sgNames.tpArea,
                force = "neutral",
                position = util.vector2Add(pos, {x = 0, y = -1.8}),
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
        util.addToGlobal("stargate", entity, content)

        ent.destroy()
    elseif ent.name == sgNames.dhdName then --dhd placed
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

	if ent.name == sgNames.entity or ent.name == sgNames.entitySignaled then
        local sg = util.findInGlobal("stargate", ent)
        if sg and sg.oldTiles then
            for i = #sg.oldTiles, 1, -1 do
                local tile = sg.oldTiles[i]
                if ent.surface.get_tile(tile.position.x, tile.position.y).name == "nuclear-ground" then
                    table.remove(sg.oldTiles, i)
                end
            end
            ent.surface.set_tiles(sg.oldTiles)
        end

        util.removeFromGlobal("stargate", ent)

    elseif ent.name == sgNames.dhdName then
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

function GuiOpened(e)
    local player = game.players[e.player_index]

    if e.entity and e.entity.name == sgNames.dhdName then
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

    if e.entity and e.entity.name == sgNames.entitySignaled then
        player.opened = nil
    end
end

function OnDamaged(e)
    local entity = e.entity
    if not entity or entity and not entity.valid then return end
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
                        position = entity.position,
                        force = "neutral",
                    }
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
