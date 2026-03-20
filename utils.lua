local functions = {}

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

return functions