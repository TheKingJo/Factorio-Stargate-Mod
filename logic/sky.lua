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
        areas = true,     --[forceName][planetName] = area
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
    surface.daytime = 0.5
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
    force.chart(surface, area.area)

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

--re-chart only the areas the force still owns, so deleted areas vanish from its map
local function rechartForce(force)
    local surface = Sky.getSurface(false)
    if not surface or not force or not force.valid then return end
    force.clear_chart(surface)

    for _, area in pairs(storage.sky.areas[force.name] or {}) do
        force.chart(surface, area.area)
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
    local areas = storage.sky.areas[e.source_name]
    if not areas then return end

    for _, area in pairs(areas) do
        destroyArea(area)
    end
    storage.sky.areas[e.source_name] = nil --row stays reserved forever, slot is unusable from now on
end

function Sky.OnPreSurfaceDeleted(e)
    local surface = game.surfaces[e.surface_index]
    if not surface then return end

    if util.isSkySurface(surface) then
        storage.sky = nil
        Sky.initStorage()
        return
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

function Sky.registerCommands()
    --/sky [unhide] - view the sky area of the planet the player physically on
    commands.add_command("sky", nil, function(command)
        local player = game.get_player(command.player_index)
        if not player then return end
        local planet = player.physical_surface
        if not Sky.isValidPlanet(planet) then player.print("Kein gültiger Planet: "..planet.name) return end
        local area = Sky.getArea(player.force, planet.name, true)

        if command.parameter == "unhide" then
            player.force.set_surface_hidden(Sky.getSurface(true), false)
        end

        local ok, err = Sky.view(player, area)
        player.print("Sky area "..planet.name.." [col "..area.col..", row "..area.row.."]: "..(ok and "ok" or ("FEHLER: "..tostring(err))))
    end)

    --/skyStars [n] - spawn n random test stars into your area of current planet
    commands.add_command("skyStars", nil, function(command)
        local player = game.get_player(command.player_index)
        if not player then return end
        local planet = player.physical_surface
        if not Sky.isValidPlanet(planet) then return end
        local area = Sky.getArea(player.force, planet.name, true)

        Sky.spawnTestStars(area, tonumber(command.parameter) or 10)
        player.print("Sterne gespawnt: "..#area.stars)
    end)

    --/skyDelete - deletes the whole sky surface + storage
    commands.add_command("skyDelete", nil, function(command)
        local surface = Sky.getSurface(false)
        if surface then game.delete_surface(surface) end
        storage.sky = nil

        Sky.initStorage()
        game.print("Sky surface gelöscht")
    end)
end
