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
        forceRows = true, --[forceName] = row index
        nextRow = 0,
        forceCols = true, --[forceName] = next free column index
        areas = true,     --[forceName][surfaceName] = area
        sessions = true,  --[player_index] = {area, character, observatory}
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

---@param force LuaForce
---@param planetName string
---@param create boolean? allocate a new area if none exists
function Sky.getArea(force, planetName, create)
    local sky, forceN = storage.sky, force.name
    if sky.areas[forceN] and sky.areas[forceN][planetName] then
        return sky.areas[forceN][planetName]
    end
    if not create then return nil end

    if sky.forceRows[forceN] == nil then
        sky.forceRows[forceN] = sky.nextRow
        sky.nextRow = sky.nextRow + 1
        sky.forceCols[forceN] = 0
    end
    local row, col = sky.forceRows[forceN], sky.forceCols[forceN]
    sky.forceCols[forceN] = col + 1

    local lt = {x = col * STRIDE, y = row * STRIDE}
    local area = {
        planet = planetName,
        force = forceN,
        col = col,
        row = row,
        area = {left_top = lt, right_bottom = {x = lt.x + AREA_SIZE, y = lt.y + AREA_SIZE}},
        center = {x = lt.x + AREA_SIZE / 2, y = lt.y + AREA_SIZE / 2},
        stars = {},
    }

    local surface = Sky.getSurface(true)
    surface.request_to_generate_chunks(area.center, 1)
    surface.force_generate_chunk_requests()

    area.radar = surface.create_entity{name = skyNames.radar, position = area.center, force = force}
    area.radar.destructible = false
    area.radar.disabled_by_script = true --only active while someone looks at this area

    sky.areas[forceN] = sky.areas[forceN] or {}
    sky.areas[forceN][planetName] = area

    return area
end

local function destroyArea(area)
    local surface = Sky.getSurface(false)
    if not surface then return end

    for _, ent in pairs(surface.find_entities_filtered{area = area.area}) do
        ent.destroy()
    end
end

--re-chart only the areas currently viewed by players of the force, everything else vanishes from its map
local function rechartForce(force)
    local surface = Sky.getSurface(false)
    if not surface or not force or not force.valid then return end
    force.clear_chart(surface)

    for _, session in pairs(storage.sky.sessions) do
        local area = session.area
        if area.force == force.name and storage.sky.areas[force.name] and storage.sky.areas[force.name][area.planet] == area then
            force.chart(surface, area.area)
        end
    end
end

local function isAreaViewed(area)
    for _, session in pairs(storage.sky.sessions) do
        if session.area == area then return true end
    end

    return false
end

local function setRadar(area, state)
    if area.radar and area.radar.valid then
        area.radar.disabled_by_script = not state
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

    local area = Sky.getArea(player.force, surface.name, true)
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
    player.force.chart(surface, area.area)

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
    if not isAreaViewed(area) then
        setRadar(area, false)
    end
    rechartForce(game.forces[area.force])

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

    local player = game.players[playerIndex]
    if player and player.valid and player.controller_type == defines.controllers.remote and util.isSkySurface(player.surface) then
        player.exit_remote_view()
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

    local areas = storage.sky.areas[e.source_name]
    if not areas then return end

    for _, area in pairs(areas) do
        destroyArea(area)
    end
    storage.sky.areas[e.source_name] = nil --row stays reserved forever, slot is unusable from now on
end

function Sky.OnPreSurfaceDeleted(e)
    local surface = game.surfaces[e.surface_index]

    if util.isSkySurface(surface) then
        for playerIndex, _ in pairs(storage.sky.sessions) do Sky.exit(playerIndex) end
        storage.sky = nil
        Sky.initStorage()
        return
    end

    for playerIndex, session in pairs(storage.sky.sessions) do
        if session.area.planet == surface.name then Sky.exit(playerIndex) end
    end

    for forceN, areas in pairs(storage.sky.areas) do
        local area = areas[surface.name]
        if area then
            destroyArea(area)
            areas[surface.name] = nil
            rechartForce(game.forces[forceN])
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
--Debugging
--------------------------------------------------------------------------------

function Sky.spawnTestStars(area, count)
    local surface = Sky.getSurface(true)
    local margin = 8

    for _ = 1, count do
        local pos = {
            x = area.area.left_top.x + margin + math.random() * (AREA_SIZE - 2 * margin),
            y = area.area.left_top.y + margin + math.random() * (AREA_SIZE - 2 * margin),
        }
        local star = surface.create_entity{name = skyNames.star, position = pos, force = area.force}
        star.destructible = false
        table.insert(area.stars, star)
    end
end

function Sky.spawnStarSign(player, letter)
    local force = player.force
    local surface = player.surface
    --local sky = Sky.getSurface(true)
    if not starPositions[letter] then
        player.print("That letter doesn't exist.")
        return
     end
    --local area = storage.sky.areas[force][surface]

    for _, pos in pairs(starPositions[letter]) do
        local star = surface.create_entity{name = skyNames.star, position = util.vector2Add(player.position, pos), force = force}
        star.destructible = false
        player.print("Spanwed star sign: "..letter)
        --table.insert(area.stars, star)
    end
end

function Sky.registerCommands()
    --/sky [unhide] - view the sky area of the planet the player physically on
    commands.add_command("sky", nil, function(command)
        local player = game.players[command.player_index]
        local surface = player.physical_surface
        if not Sky.isValidPlanet(surface) then player.print("Not a valid planet: "..surface.name) return end

        Sky.enter(player)
    end)

    --/skyStars [n] - spawn n random test stars into your area of current planet
    commands.add_command("skyStars", nil, function(command)
        local player = game.players[command.player_index]
        local surface = player.physical_surface
        if not Sky.isValidPlanet(surface) then return end
        local area = Sky.getArea(player.force, surface.name, true)

        Sky.spawnTestStars(area, tonumber(command.parameter) or 10)
        player.print("Spanwed stars: "..#area.stars)
    end)

    --/skyStar [A-s] - spawn a star sign (glyph)
    commands.add_command("skyStar", nil, function(command)
        Sky.spawnStarSign(game.players[command.player_index], command.parameter)
    end)

    --/skyDelete - deletes the whole sky surface + storage
    commands.add_command("skyDelete", nil, function(command)
        local surface = Sky.getSurface(false)
        if surface then game.delete_surface(surface) end
        storage.sky = nil

        Sky.initStorage()
        game.print("Deleted sky surface")
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
