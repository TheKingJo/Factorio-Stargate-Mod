local functions = {}
local dhdSearchRadius = 15
local opposite = {
    dhd = "stargate",
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
    return {x = (vec1.x + vec2.x), y = (vec1.y + vec2.y)}
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
---@param entity LuaEntity the created entity
---@param excludeEntity? LuaEntity entity to ignore in search
---@return LuaEntity can be nil when nothing found
function functions.findEntity(name, entity, excludeEntity)
    local entities = game.surfaces[entity.surface_index].find_entities_filtered{position = entity.position, radius = dhdSearchRadius, name = "kj_"..name}
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

---@return table [if it exists in global]
function functions.findInGlobal(name, entity)
    if entity == nil then return nil end
    local sName = entity.surface.name
    if not storage[name] then storage[name] = {} end
    if not storage[name][sName] then storage[name][sName] = {} end

    for _, object in pairs(storage[name][sName]) do
        if object.entity == entity then
            return object
        end
    end

    return nil
end

---@param name string name of storage table
---@param entity LuaEntity the entity of the entry to be added
---@param addContent? table additional content to add to the storage entry
function functions.addToGlobal(name, entity, addContent)
    local sName = entity.surface.name
    if not storage[name] then return end
    if not storage[name][sName] then return end

    local shortestOppEnt = functions.findEntity(opposite[name], entity)
    local shortestOppEntObj = functions.findInGlobal(opposite[name], shortestOppEnt)

    local content = {
        entity = entity,
        pos = entity.position,
        [opposite[name]] = shortestOppEntObj,
    }
    for k, v in pairs(addContent) do content[k] = v end
	table.insert(storage[name][sName], content)

    if shortestOppEnt ~= nil and shortestOppEntObj ~= nil and shortestOppEntObj[name] == nil then
        shortestOppEntObj[name] = storage[name][sName][#storage[name][sName]]
    else
        game.print("Couldn't find "..opposite[name].." nearby!")
    end
end

---@param name string name of storage table
---@param entity LuaEntity the entity of the entry to be deleted
function functions.removeFromGlobal(name, entity)
    local sName = entity.surface.name
    if not storage[name] then return end
    if not storage[name][sName] then return end

    for i, storObj in ipairs(storage[name][sName]) do
        if storObj.entity == entity then
            if storObj[opposite[name]] ~= nil then --object to be removed has mapped opposite entity - find new or nil it
                local shortestOppEnt = functions.findEntity(name, storObj[opposite[name]].entity, entity)
                local shortestOppEntObj = functions.findInGlobal(name, shortestOppEnt)
                storObj[opposite[name]][name] = shortestOppEntObj

                if shortestOppEntObj ~= nil then
                    shortestOppEntObj[opposite[name]] = storObj[opposite[name]]
                end
            end

            table.remove(storage[name][sName], i)
            return
        end
    end
end

return functions