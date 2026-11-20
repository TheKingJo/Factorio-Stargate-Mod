--sky surface for observatory feature / finding out address glyphs
--one shared surface: every force gets a row, every planet of that force a column (x)
--each area = 3x3 chunks + empty gap so radar coverage never overlaps
--slots are never reused: deleted forces/planets just leave unusable areas behind

Sky = {}
local CHUNK = 32
local AREA_CHUNKS = 3
local STRIDE = (AREA_CHUNKS + 1) * CHUNK
local AREA_SIZE = AREA_CHUNKS * CHUNK

function Sky.initStorage()
    storage.sky = storage.sky or {}
    local properties = {
        forceRows = true, --[forceN] = row index
        nextRow = 0,
        forceCols = true, --[forceN] = next free column index
        planetAreas = true,     --[forceN][surfaceName] = area
        sessions = true,  --[player_index] = {area, character, observatory}
        starLookup = true, --[star_unit_number] = {forceN = forceN, planet = planetName, letter = letter, nodeIndex = nodeIndex}
        dirtyAreas = true, --[forceN] = {[planet] = true}
    }

    for prop, value in pairs(properties) do
        if value == true then
            storage.sky[prop] = storage.sky[prop] or {}
        else
            storage.sky[prop] = storage.sky[prop] or value
        end
    end
end

---@param create boolean? create the surface if it doesn't exist yet
---@return LuaSurface?
function Sky.getSurface(create)
    local surface = game.surfaces[skyNames.surface]
    if surface or not create then return surface end

    surface = game.create_surface(skyNames.surface, {
        autoplace_settings = {
            entity = {treat_missing_as_default = false, settings = {}},
            decorative = {treat_missing_as_default = false, settings = {}},
        },
        default_enable_all_autoplace_controls = false,
        no_enemies_mode = true,
        peaceful_mode = true,
    })
    surface.generate_with_lab_tiles = true
    surface.freeze_daytime = true
    surface.daytime = 0
    surface.show_clouds = false

    for _, force in pairs(game.forces) do
        force.set_surface_hidden(surface, true)
    end

    return surface
end

--planet = real planet surface with a stargate address
function Sky.isValidPlanet(surface)
    return surface ~= nil
        and surface.valid
        and surface.platform == nil
        and not util.isSkySurface(surface)
        and storage.addresses[surface.name] ~= nil
end

function Sky.getArea(force, planet)
    local sky, forceN = storage.sky, force.name
    if sky.planetAreas[forceN] and sky.planetAreas[forceN][planet] then
        return sky.planetAreas[forceN][planet]
    end

    if sky.forceRows[forceN] == nil then
        sky.forceRows[forceN] = sky.nextRow
        sky.nextRow = sky.nextRow + 1
        sky.forceCols[forceN] = 0
    end
    local row, col = sky.forceRows[forceN], sky.forceCols[forceN]
    sky.forceCols[forceN] = col + 1

    local lt = {x = col * STRIDE, y = row * STRIDE}
    local area = {
        planet = planet,
        force = forceN,
        col = col,
        row = row,
        area = {left_top = lt, right_bottom = {x = lt.x + AREA_SIZE, y = lt.y + AREA_SIZE}},
        center = {x = lt.x + AREA_SIZE / 2, y = lt.y + AREA_SIZE / 2},
        glyphs = {},
    }

    local surface = Sky.getSurface(true)
    surface.request_to_generate_chunks(area.center, 1)
    surface.force_generate_chunk_requests()

    sky.planetAreas[forceN] = sky.planetAreas[forceN] or {}
    sky.planetAreas[forceN][planet] = area

    area.title = rendering.draw_text{
        text = {"", {"space-location-name."..planet}},
        surface = surface,
        target = {y = area.area.left_top.y, x = (area.area.right_bottom.x - area.area.left_top.x) / 2 + area.area.left_top.x},
        color = {221/255, 127/255, 33/255, 1},
        scale = 10,
        force = force,
        alignment = "center",
    }

    local glyphs
    repeat
        glyphs = util.poissonDiskSampling(area.area, 25, 15)
    until #glyphs >= 6
    game.print(#glyphs.." glyph positions found")

    local address = util.stringToArray(storage.addresses[planet])
    for _, letter in ipairs(address) do
        local i = math.random(#glyphs)
        Sky.spawnGlyph(surface, planet, glyphs[i], force, letter)

        local mask = rendering.draw_sprite{
            sprite = "kj_sg_glyph_mask_"..letter,
            x_scale = 11,
            y_scale = 11,
            target = glyphs[i],
            surface = surface,
            render_layer = "object-under",
            tint = {0.1, 0.1, 0.1, 0},
            light_mode = "glow",
            visible = false,
        }
        if area.glyphs[letter] then
            area.glyphs[letter].mask = mask
            area.glyphs[letter].position = glyphs[i]
        end
        table.remove(glyphs, i)
    end

    local randomStars = {}
    randomStars = util.poissonDiskSampling(area.area, 20, 3)
    for _ = 1, 10, 1 do
        --table.insert(randomStars, {x = math.random(area.area.left_top.x + 1.5, area.area.right_bottom.x - 1.5),
                                   --y = math.random(area.area.left_top.y + 1.5, area.area.right_bottom.y - 1.5)})
    end

    for _, star in ipairs(randomStars) do
        star = surface.create_entity{name = skyNames.star, position = star, force = force}
        Sky.drawStar(star, surface)
        star.destructible = false
    end
    game.print(#randomStars.." random stars")

    return area
end

local function destroyArea(area)
    local surface = Sky.getSurface(false)
    if not surface then return end

    for _, ent in pairs(surface.find_entities_filtered{area = area.area}) do
        ent.destroy()
    end
end

local function reduceArea(area)
    return {
        left_top = {x = area.left_top.x + 1, y = area.left_top.y + 1},
        right_bottom = {x = area.right_bottom.x - 1, y = area.right_bottom.y - 1}
    }
end

local function isAreaViewed(area)
    for _, session in pairs(storage.sky.sessions) do
        if session.area == area then return true end
    end

    return false
end

local function unchartArea(force, area)
    local surface = Sky.getSurface(false)
    if not surface or not force or not force.valid then return end

    local min_cx = math.floor(area.area.left_top.x / 32)
    local max_cx = math.floor(area.area.right_bottom.x / 32)
    local min_cy = math.floor(area.area.left_top.y / 32)
    local max_cy = math.floor(area.area.right_bottom.y / 32)

    for cx = min_cx, max_cx do
        for cy = min_cy, max_cy do
            force.unchart_chunk({x = cx, y = cy}, surface)
        end
    end
end

local function setRadar(area, state)
    local surface = Sky.getSurface(false)
    if not surface then return end

    if state then
        if not area.radar or not area.radar.valid then
            local force = game.forces[area.force]
            area.radar = surface.create_entity{name = skyNames.radar, position = area.center, force = force}
            area.radar.destructible = false
        end
        --game.print("Spawned radar on "..area.planet)
    else
        if area.radar and area.radar.valid then
            area.radar.destroy()
            area.radar = nil
            --game.print("Destroyed radar on "..area.planet)
        end
    end
end

--switches the player into remote view of the given area
---@return boolean success, string? error
function Sky.view(player, area)
    local surface = Sky.getSurface(true)
    local ok, err = pcall(player.set_controller, {
        type = defines.controllers.remote,
        surface = surface,
        position = area.center,
    })

    return ok, err
end

---player enters the sky through an observatory
function Sky.enter(player, observatory)
    local character = player.character
    if storage.sky.sessions[player.index] then return end
    local surface = (observatory and observatory.surface) or player.surface

    if not Sky.isValidPlanet(surface) then
        player.print("There's no sky here.")
        return
    end

    local area = Sky.getArea(player.force, surface.name)
    local surface = Sky.getSurface(true)

    --character hides inside the observatory, enemies have to destroy it first
    if character and observatory then
        character.teleport(observatory.position)
    end
    storage.sky.sessions[player.index] = {
        area = area,
        character = character,
        observatory = observatory,
    }

    setRadar(area, true)
    player.force.chart(surface, reduceArea(area.area))

    local ok, err = Sky.view(player, area)
    if not ok then
        player.print("Sky view failed: "..tostring(err))
        Sky.exit(player.index)
    end
end

function Sky.exit(playerIndex)
    local session = storage.sky.sessions[playerIndex]
    if not session then return end
    storage.sky.sessions[playerIndex] = nil

    local area = session.area
    local player = game.players[playerIndex]
    if player and player.valid and player.controller_type == defines.controllers.remote and util.isSkySurface(player.surface) then
        player.exit_remote_view()
    end

    --put character back in front of observatory
    local character, observatory = session.character, session.observatory
    if character and character.valid then
        local pos = character.position
        if observatory and observatory.valid then
            pos = {x = observatory.position.x, y = observatory.bounding_box.right_bottom.y + 0.5}
        end
        pos = character.surface.find_non_colliding_position(character.name, pos, 10, 0.5) or pos
        character.teleport(pos)
    end

    if not isAreaViewed(area) then
        setRadar(area, false)
        unchartArea(game.forces[area.force], area)
    end
end

--ends all sessions bound to an observatory
function Sky.OnObservatoryRemoved(entity)
    for playerIndex, session in pairs(storage.sky.sessions) do
        if session.observatory == entity then
            Sky.exit(playerIndex)
        end
    end
end

function Sky.drawStar(target, surface)
    local scale = util.rndFloat(0.5, 1)
    rendering.draw_animation{
        animation = "kj_sg_star",
        orientation = math.random(),
        x_scale = scale,
        y_scale = scale,
        target = target,
        surface = surface,
        render_layer = "object",
        animation_speed = util.rndFloat(0.15, 0.25),
        tint = {util.rndFloat(0.75, 1), util.rndFloat(0.75, 1), util.rndFloat(0.75, 1), 1},
    }
end

function Sky.spawnGlyph(surface, planet, position, force, letter, debug)
    local area
    if not debug then
        Sky.getSurface(true)
        area = storage.sky.planetAreas[force.name][planet]
        area.glyphs[letter] = {
            stars = {},
            solved = false,
        }
    end

    if not starPositions[letter] then
        game.print("That letter doesn't exist.")
        return
     end

    for nodeIdx, pos in pairs(starPositions[letter].points) do
        local star = surface.create_entity{name = skyNames.star, position = util.vector2Add(position, {20*pos.x, -20*pos.y}), force = force}
        Sky.drawStar(star, surface)
        star.destructible = false
        --game.print("Spawned star sign: "..letter)

        if not debug then
            table.insert(area.glyphs[letter].stars, star)
            if storage.sky.starLookup then
                storage.sky.starLookup[star.unit_number] = {
                    forceN = force.name,
                    planet = planet,
                    letter = letter,
                    nodeIndex = nodeIdx
                }
            end
        end
    end
end

--------------------------------------------------------------------------------
--events
--------------------------------------------------------------------------------

function Sky.OnChunkGenerated(e)
    local tiles, i = {}, 0
    local lt = e.area.left_top

    for x = lt.x, lt.x + CHUNK - 1 do
        for y = lt.y, lt.y + CHUNK - 1 do
            i = i + 1
            tiles[i] = {name = skyNames.tile, position = {x, y}}
        end
    end
    e.surface.set_tiles(tiles, false)
end

function Sky.OnForceCreated(e)
    local surface = Sky.getSurface(false)

    if surface then
        e.force.set_surface_hidden(surface, true)
    end
end

function Sky.OnForcesMerged(e)
    for playerIndex, session in pairs(storage.sky.sessions) do
        if session.area.force == e.source_name then Sky.exit(playerIndex) end
    end

    local planetAreas = storage.sky.planetAreas[e.source_name]
    if not planetAreas then return end

    for _, area in pairs(planetAreas) do
        destroyArea(area)
    end
    storage.sky.planetAreas[e.source_name] = nil --row stays reserved forever, slot is unusable from now on
end

function Sky.OnPreSurfaceDeleted(e)
    local surface = game.surfaces[e.surface_index]

    if util.isSkySurface(surface) then
        for playerIndex, _ in pairs(storage.sky.sessions) do Sky.exit(playerIndex) end
        storage.sky = nil
        Sky.initStorage()
        return
    end

    --TODO löscht das hier einfach alles wenn eine surface gelöscht wird??

    for playerIndex, session in pairs(storage.sky.sessions) do
        if session.area.planet == surface.name then Sky.exit(playerIndex) end
    end

    for forceN, planetAreas in pairs(storage.sky.planetAreas) do
        if planetAreas[surface.name] then
            destroyArea(planetAreas[surface.name])
            planetAreas[surface.name] = nil
            game.forces[forceN].clear_chart(Sky.getSurface(false))
        end
    end
end

--------------------------------------------------------------------------------
--session watchers
--------------------------------------------------------------------------------

--player left remote view (escape, map key, clicking on character...)
function Sky.OnPlayerControllerChanged(e)
    if not storage.sky.sessions[e.player_index] then return end
    local player = game.players[e.player_index]

    if player.controller_type ~= defines.controllers.remote then
        Sky.exit(e.player_index)
    end
end

--player switched to another surface inside remote view
function Sky.OnPlayerChangedSurface(e)
    if not storage.sky.sessions[e.player_index] then return end
    local player = game.players[e.player_index]

    if not util.isSkySurface(player.surface) then
        Sky.exit(e.player_index)
    end
end

function Sky.OnPlayerGone(e)
    Sky.exit(e.player_index)
end

--------------------------------------------------------------------------------
--puzzle verification
--------------------------------------------------------------------------------

function Sky.markDirty(forceN, planet)
    storage.sky.dirtyAreas = storage.sky.dirtyAreas or {}
    storage.sky.dirtyAreas[forceN] = storage.sky.dirtyAreas[forceN] or {}
    storage.sky.dirtyAreas[forceN][planet] = true
end

function Sky.OnSelectedEntityChanged(e)
    local player = game.players[e.player_index]
    --if not player or not player.valid then return end
    if not util.isSkySurface(player.surface) then return end

    local selected = player.selected
    if selected and selected.valid and selected.name == skyNames.star then
        local star = storage.sky.starLookup and storage.sky.starLookup[selected.unit_number]
        if star then
            Sky.markDirty(star.forceN, star.planet)
        else
            --might be a random star or unindexed star; find out which area it's in
            for force, planetAreas in pairs(storage.sky.planetAreas or {}) do
                for planet, area in pairs(planetAreas) do
                    if util.positionInBoundingBox(selected.position, area.area) then
                        Sky.markDirty(force, planet)
                        return
                    end
                end
            end
        end
    end
end

function Sky.checkGlyph(forceN, planet, letter, glyphData)
    if glyphData.solved then return end
    local pattern = starPositions[letter]
    if not pattern or not pattern.edges then return end

    local stars = glyphData.stars
    if not stars or #stars == 0 then return end

    --verify star validity
    local starsInGlyph = {}
    for nodeIdx, star in ipairs(stars) do
        if not star.valid then return end
        starsInGlyph[star.unit_number] = nodeIdx
    end

    local actualEdges = {}
    local actualEdgeCount = 0

    local function inspectConnector(conn)
        if not conn then return end

        for _, connection in ipairs(conn.connections or {}) do
            local targetOwner = connection.target and connection.target.owner

            if targetOwner and targetOwner.valid then
                local targetNode = starsInGlyph[targetOwner.unit_number]
                if not targetNode then
                    --connected to random star or star from other glyph -> invalid!
                    return
                end
            end
        end
        return true
    end

    for nodeIdx, star in ipairs(stars) do
        local redConn = star.get_wire_connector(defines.wire_connector_id.circuit_red, true)
        local greenConn = star.get_wire_connector(defines.wire_connector_id.circuit_green, true)

        if not inspectConnector(redConn) or not inspectConnector(greenConn) then
            return
        end

        local function addEdgesFromConnector(conn)
            if not conn then return end

            for _, connection in ipairs(conn.connections or {}) do
                local targetOwner = connection.target and connection.target.owner

                if targetOwner and targetOwner.valid then
                    local targetNode = starsInGlyph[targetOwner.unit_number]

                    if targetNode and targetNode ~= nodeIdx then
                        local n1 = math.min(nodeIdx, targetNode)
                        local n2 = math.max(nodeIdx, targetNode)
                        local key = n1 .. "-" .. n2

                        if not actualEdges[key] then
                            actualEdges[key] = true
                            actualEdgeCount = actualEdgeCount + 1
                        end
                    end
                end
            end
        end

        addEdgesFromConnector(redConn)
        addEdgesFromConnector(greenConn)
    end

    --comparison of required edges
    local reqEdges = {}
    local reqCount = 0

    for _, edge in ipairs(pattern.edges) do
        local n1 = math.min(edge[1], edge[2])
        local n2 = math.max(edge[1], edge[2])
        local key = n1 .. "-" .. n2

        if not reqEdges[key] then
            reqEdges[key] = true
            reqCount = reqCount + 1
        end
    end

    if actualEdgeCount ~= reqCount then
        return
    end

    for key, _ in pairs(reqEdges) do
        if not actualEdges[key] then
            return
        end
    end

    --pattern matched - solve glyph
    glyphData.solved = true

    --disconnecting player wires for visual quality
    local surface = Sky.getSurface(false)
    for _, star in ipairs(stars) do
        local redConn = star.get_wire_connector(defines.wire_connector_id.circuit_red, false)
        if redConn then redConn.disconnect_all() end
        local greenConn = star.get_wire_connector(defines.wire_connector_id.circuit_green, false)
        if greenConn then greenConn.disconnect_all() end
    end

    --[[script wire connections
    for _, edge in ipairs(pattern.edges) do
        local starA = stars[edge[1]]--[[
        local starB = stars[edge[2]]--[[

        if starA and starB and starA.valid and starB.valid then
            local connA = starA.get_wire_connector(defines.wire_connector_id.circuit_green, true)
            local connB = starB.get_wire_connector(defines.wire_connector_id.circuit_green, true)

            if connA and connB then
                connA.connect_to(connB, false, defines.wire_origin.script)
            end
        end
    end]]

    --visuals & sound
    if glyphData.mask and glyphData.mask.valid then
        glyphData.mask.visible = true
    end

    local force = game.forces[forceN]
    if force and force.valid then
        force.print({"glyphDiscovered", {"glyph_"..letter}, {"space-location-name."..planet}})
    end

    --check if all 6 glyphs of this planet are solved
    local area = storage.sky.planetAreas[forceN] and storage.sky.planetAreas[forceN][planet]
    if area and area.glyphs then
        local allSolved = true

        for _, g in pairs(area.glyphs) do
            if not g.solved then
                allSolved = false
                break
            end
        end

        if allSolved then
            util.forceSurfaceSetup(force, game.surfaces[planet], 2)
            GUI.RefreshAllAddBks(forceN, planet, 2)
            if force and force.valid then
                force.print({"addressDiscovered", {"space-location-name."..planet}})
                force.play_sound {
                    path = "kj_stargate_found_address",
                    position = glyphData.position,
                    volume_modifier = 0.75
                }
            end
        else
            force.play_sound {
                path = "kj_stargate_found_glyph",
                position = glyphData.position,
                volume_modifier = 0.75
            }
        end
    end

    return true
end

function Sky.checkDirtyAreas()
    local dirtyAreas = storage.sky.dirtyAreas
    if not dirtyAreas then return end

    for force, planets in pairs(dirtyAreas) do
        for planet, isDirty in pairs(planets) do
            if isDirty then
                planets[planet] = nil
                local area = storage.sky.planetAreas[force] and storage.sky.planetAreas[force][planet]
                if area and area.glyphs then
                    for letter, glyphData in pairs(area.glyphs) do
                        if not glyphData.solved then
                            Sky.checkGlyph(force, planet, letter, glyphData)
                        end
                    end
                end
            end
        end
    end

    --check any active session's area as backup
    for _, session in pairs(storage.sky.sessions or {}) do
        local area = session.area
        if area and area.glyphs then
            for letter, glyphData in pairs(area.glyphs) do
                if not glyphData.solved then
                    Sky.checkGlyph(area.force, area.planet, letter, glyphData)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
--Debugging
--------------------------------------------------------------------------------

--TODO poisson verteilung der positionen der glyphen im areal
-- mindestabstand, auch vom rand. suchen bis kombination gefunden
-- ansonsten fallback mit kanten der oberen und unteren drei mit mitte

function Sky.spawnGlyphTest(player, letter)
    local force = player.force
    local surface = player.surface
    if not starPositions[letter] then
        player.print("That letter doesn't exist.")
        return
     end

    Sky.spawnGlyph(surface, surface.name, player.position, force, letter, true)
    game.print("Spawned glyph: "..letter)
    util.playSoundOnSurface(surface, player.position, "kj_stargate_found_glyph")

    rendering.draw_sprite{
        sprite = "kj_sg_glyph_mask_"..letter,
        x_scale = 11,
        y_scale = 11,
        target = player.position,
        surface = surface,
        render_layer = "object-under",
        tint = {0.1, 0.1, 0.1, 0},
        light_mode = "glow",
    }
end

function Sky.registerCommands()
    --/sky [unhide] - view the sky area of the planet the player physically on
    commands.add_command("sky", nil, function(command)
        local player = game.players[command.player_index]
        local surface = player.physical_surface
        if not Sky.isValidPlanet(surface) then player.print("Not a valid planet: "..surface.name) return end

        Sky.enter(player)
    end)

    --/skyStar [A-s] - spawn a star sign (glyph)
    commands.add_command("skyStar", nil, function(command)
        Sky.spawnGlyphTest(game.players[command.player_index], command.parameter)
    end)

    --/skyDelete - deletes the whole sky surface + storage
    commands.add_command("skyDelete", nil, function(command)
        local surface = Sky.getSurface(false)
        if surface then game.delete_surface(surface) end
        storage.sky = nil

        Sky.initStorage()
        game.print("Deleted sky surface.")
    end)

    --/skySavePattern
    commands.add_command("skySavePattern", nil, function(command)
        local player = game.players[command.player_index]
        local range, pos, surface = 50, player.position, player.surface
        local area = {
            left_top = {y = pos.y - range, x = pos.x - range},
            right_bottom = {y = pos.y + range, x = pos.x + range}
        }
        local entities, positions = surface.find_entities_filtered{name = "kj_sg_sky_star", area = area}, {}

        for _, entity in pairs(entities) do
            positions[#positions + 1] = {
                x = entity.position.x - pos.x,
                y = entity.position.y - pos.y
            }
        end

        local json = helpers.table_to_json(positions)
        helpers.write_file("entity_positions.json", json, false, player.index )

        player.print("Export done: "..#positions.." entities found.")
        --helpers.json_to_table(json)
    end)
end

--TODO verschiedene schwierigkeitsgrade spawnen unterschiedlich viele rndSterne