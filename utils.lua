local functions = {}
local dhdSearchRadius = 15
local contrary = {
    dhd = "stargate",
    stargates = "dhd",
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

function functions.findEntity(name, entName, entity, excludeEntity)
    local entities = game.surfaces[entity.surface_index].find_entities_filtered{position = entity.position, radius = dhdSearchRadius, name = entName}
    local distance = 100000
    local shortestEntity
    for _, ent in ipairs(entities) do
        if ent ~= excludeEntity then
            local dist = functions.getDistance(ent.position, entity.position)
            if dist < distance and functions.findInGlobal(name, entity) == nil then --- hier stimmt was nich, er muss feststellen ob das schon belegt ist
                shortestEntity = ent
                distance = dist
            end
        end
    end
    return shortestEntity
end

function functions.removeFromGlobal(name, entName, entity)
    local sName = entity.surface.name
    if not storage[name] then return end
    if not storage[name][sName] then return end

    for i, obj in ipairs(storage[name][sName]) do
        if obj.entity == entity then
            if obj[contrary[name]] ~= nil then
                local entry = functions.findInGlobal(name, functions.findEntity(name, entName, obj[contrary[name]].entity, entity))
                obj[contrary[name]][name] = entry

                if entry ~= nil then
                    entry[contrary[name]] = obj[contrary[name]]
                end
            end

            table.remove(storage[name][sName], i)
            return
        end
    end
end

return functions