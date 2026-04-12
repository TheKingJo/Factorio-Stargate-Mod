for _, dmgType in pairs(data.raw["damage-type"]) do
    if dmgType.name == "explosion" then goto continue end
    table.insert(data.raw["simple-entity-with-owner"]["kj_stargate_transferArea"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })
    ::continue::
end