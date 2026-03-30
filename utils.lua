local functions = {}
local dhdSearchRadius = 15
local opposite = {
    dhd = "stargate",
    stargate = "dhd",
}
local oppositeEntity = {
    dhd = "stargate_transferArea",
    stargate = "dhd",
}

function functions.getDistance(pos1, pos2)
	return math.sqrt((pos2.x - pos1.x)^2 + (pos2.y - pos1.y)^2)
end

function functions.hash_fnv1a(str)
    local hash = 2166136261
    for i = 1, #str do
        hash = bit32.bxor(hash, string.byte(str, i))
        hash = (hash * 16777619) % 4294967296
    end
    return hash
end

function functions.vector2Add(vec1, vec2)
    return {x = ((vec1.x or vec1[1]) + (vec2.x or vec2[1])), y = ((vec1.y or vec1[2]) + (vec2.y or vec2[2]))}
end

function functions.getRotatedBox(area, rotation)
    local angle = rotation * 2 * math.pi
    local minX = math.min(area.left_top.x, area.right_bottom.x)
    local maxX = math.max(area.left_top.x, area.right_bottom.x)
    local minY = math.min(area.left_top.y, area.right_bottom.y)
    local maxY = math.max(area.left_top.y, area.right_bottom.y)

    --Center
    local cx = (minX + maxX) / 2
    local cy = (minY + maxY) / 2
    --Corners in unrotated box
    local corners = {
        {x = minX, y = minY},
        {x = maxX, y = minY},
        {x = maxX, y = maxY},
        {x = minX, y = maxY},
    }

    local cosA = math.cos(angle)
    local sinA = math.sin(angle)
    local rotated = {}

    for i, p in ipairs(corners) do
        local dx = p.x - cx
        local dy = p.y - cy

        --Rotation clockwise
        local rx = dx * cosA + dy * sinA
        local ry = -dx * sinA + dy * cosA

        rotated[i] = {
            x = cx + rx,
            y = cy + ry
        }
    end

    return rotated
end

function functions.pointInAABB(p, area)
    --local minX = math.min(area.left_top.x, area.right_bottom.x)
    --local maxX = math.max(area.left_top.x, area.right_bottom.x)
    --local minY = math.min(area.left_top.y, area.right_bottom.y)
    --local maxY = math.max(area.left_top.y, area.right_bottom.y)
    local minX = area.left_top.x
    local maxX = area.right_bottom.x
    local minY = area.left_top.y
    local maxY = area.right_bottom.y

    return p.x > minX and p.x < maxX and
           p.y > minY and p.y < maxY
end

function functions.rotatedBoxInsideBoundingBox(area1, orientation, area2)
    local rotatedBox = functions.getRotatedBox(area1, orientation)

    for _, p in ipairs(rotatedBox) do
        if functions.pointInAABB(p, area2) then
            return true
        end
    end
    return false
end

function functions.positionInBoundingBox(pos, area)
    --pos = {x = 0, y = 0}
    --area = {{x = -1, y = -1}, {x = 1, y = 1}}

    if pos.x > area.left_top.x and pos.x < area.right_bottom.x then
        if pos.y > area.left_top.y and pos.y < area.right_bottom.y then
            return true
        end
    end

    return false
end

---@param name string name of storage table
---@param entName string name of the entity
---@param entity LuaEntity the created entity
---@param excludeEntity? LuaEntity entity to ignore in search
---@return LuaEntity can be nil when nothing found
function functions.findEntity(name, entName, entity, excludeEntity)
    local entities = game.surfaces[entity.surface_index].find_entities_filtered{position = entity.position, radius = dhdSearchRadius, name = "kj_"..entName}
    local distance = 100000
    local shortestEntity
    for _, ent in ipairs(entities) do
        if ent ~= excludeEntity then
            local dist = functions.getDistance(ent.position, entity.position)
            local obj = functions.findInGlobal(name, ent)
            if dist < distance and obj ~= nil and obj[opposite[name]] == nil then
                shortestEntity = ent
                distance = dist
            end
        end
    end
    return shortestEntity
end

function functions.findIDInGlobal(name, surface, id)
    if not surface and not id then return nil, nil end
    storage[name] = storage[name] or {}
    if not storage[name][surface] then return nil, nil end

    if id then
        if storage[name][surface][id] then
            return storage[name][surface][id]
        end
    end

    return nil
end

---@return table, number [if it exists in global]
function functions.findInGlobal(name, entity)
    if entity == nil then return nil, nil end
    local sName = entity.surface.name
    storage[name] = storage[name] or {}
    if not storage[name][sName] then return nil, nil end

    for id, object in pairs(storage[name][sName]) do
        if object.entity == entity then
            return object, id
        end
    end

    return nil, nil
end

function functions.splitNameId(input)
    local surface1, id1, surface2, id2 = string.match(
            input, "^%(([^%.]+)%.(-?%d+)%)%.%(([^%.]+)%.(-?%d+)%)$"
        )
    if surface1 and surface2 and id1 and id2 then
        return surface1, surface2, tonumber(id1), tonumber(id2)
    else
        return nil, nil, nil, nil
    end
end

function functions.splitNameId2(input)
    local dhdSurface, dhdID, char = string.match(input, "^([^%.]+)%.(%d+)%.([^%.]+)$")
    if dhdSurface and dhdID and char then
        return dhdSurface, tonumber(dhdID), char
    else
        return nil, nil, nil
    end
end

---@param name string name of storage table
---@param entity LuaEntity the entity of the entry to be added
---@param addContent? table additional content to add to the storage entry
function functions.addToGlobal(name, entity, addContent)
    local sName = entity.surface.name
    local id = entity.unit_number or ((storage[name.."id"] or 0) + 1)
    storage[name.."id"] = id
    storage[name] = storage[name] or {}
    storage[name][sName] = storage[name][sName] or {}

    local shortestOppEnt = functions.findEntity(opposite[name], oppositeEntity[name], entity)
    local shortestOppEntObj = functions.findInGlobal(opposite[name], shortestOppEnt)

    local content = {
        id = id,
        entity = entity,
        pos = entity.position,
        [opposite[name]] = shortestOppEntObj,
    }
    if addContent then
        for k, v in pairs(addContent) do content[k] = v end
    end

    if name == "stargate" then
        setmetatable(content, {__index = stargate})
    else
        setmetatable(content, {__index = dhd})
    end
	storage[name][sName][id] = content

    if shortestOppEnt ~= nil and shortestOppEntObj ~= nil and shortestOppEntObj[name] == nil then
        shortestOppEntObj[name] = storage[name][sName][id]
    else
        game.print("Couldn't find "..opposite[name].." nearby!")
    end

    return storage[name][sName][id]
end

---@param name string name of storage table
---@param entity LuaEntity the entity of the entry to be deleted
function functions.removeFromGlobal(name, entity)
    local sName = entity.surface.name
    if not storage[name] then return end
    if not storage[name][sName] then return end

    for id, storObj in pairs(storage[name][sName]) do
        if storObj.entity == entity then
            local returnValue

            if storObj[opposite[name]] ~= nil then --object to be removed has mapped opposite entity - find new or nil it
                local shortestOppEnt = functions.findEntity(name, oppositeEntity[name], storObj[opposite[name]].entity, entity)
                local shortestOppEntObj = functions.findInGlobal(name, shortestOppEnt)
                storObj[opposite[name]][name] = shortestOppEntObj

                if shortestOppEntObj ~= nil then
                    shortestOppEntObj[opposite[name]] = storObj[opposite[name]]
                end

                returnValue = storObj[opposite[name]]
            end

            if storObj.childs then
                for _, ent in pairs(storObj.childs) do
                    ent.destroy()
                end
            end

            storage[name][sName][id] = nil
            return returnValue
        end
    end
end

function functions.playSoundOnSurface(surface, position, sound, volume)
	surface.play_sound {
		path = sound,
		position = position,
		volume_modifier = volume or 1
	}
end

function functions.register_handlers(handlers, namespace)
    glib.register_handlers(handlers, function(event, handler)
        handler(event.element, storage.refs[event.player_index], event)
    end, namespace)
end

function functions.setMetatablesInGlobal(name, mt)
	if storage[name] then
		for k, v in pairs(storage[name]) do
			setmetatable(v, mt)
		end
	end
end
function functions.randomSound(name, number)
    return name..math.random(1,number)
end

functions.mtMgr =
{
    assignments = {},

    assign = function(strType, metatable)
        functions.mtMgr.assignments[strType] = metatable
    end,

    set = function(obj, strType)
        obj.__mtMgr_type = strType
        return setmetatable(obj, functions.mtMgr.assignments[strType])
    end,

    crawl = function(t, f, lookup)
        if not lookup then
            lookup = {}
        end

        lookup[t] = true

        if not t.__self then
            f(t)

            for _, v in pairs(t) do
                if type(v) == "table" and not lookup[v] then
                    functions.mtMgr.crawl(v, f, lookup)
                end
            end
        end
    end,

    OnLoad = function(t)
        t = t or storage

        functions.mtMgr.crawl(storage, function(t)
            local mt = functions.mtMgr.assignments[t.__mtMgr_type]
            if mt then
                setmetatable(t, mt)
            end
        end)
    end,
}
return functions