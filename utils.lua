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
    if not storage[name] then storage[name] = {} end
    if not storage[name][surface] then storage[name][surface] = {} end

    if id then
        if storage[name][surface][id] then
            return storage[name][surface][id]
        end
    end

    return nil
end

---@return table, number [if it exists in global]
function functions.findInGlobal(name, entity)
    if entity == nil then return nil end
    local sName = entity.surface.name
    if not storage[name] then storage[name] = {} end
    if not storage[name][sName] then storage[name][sName] = {} end

    for id, object in pairs(storage[name][sName]) do
        if object.entity == entity then
            return object, id
        end
    end

    return nil, nil
end

function functions.splitNameId(input)
    local name, id, id2 = string.match(input, "^(.*)%-(%d+)%-([^%-]+)$")

    if name and id and id2 then
        return name, tonumber(id), tonumber(id2)
    else
        return nil, nil, nil
    end
end

---@param name string name of storage table
---@param entity LuaEntity the entity of the entry to be added
---@param addContent? table additional content to add to the storage entry
function functions.addToGlobal(name, entity, addContent)
    local sName = entity.surface.name
    local id = storage[name.."id"]
    if not storage[name] then storage[name] = {} end
    if not storage[name][sName] then storage[name][sName] = {} end
    if not id then
        storage[name.."id"] = 0
        id = 0
    else
        id = id + 1
    end
    if entity.unit_number then
        id = entity.unit_number
    end

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

            for k,v in pairs(t) do
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