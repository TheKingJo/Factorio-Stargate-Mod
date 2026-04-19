for _, dmgType in pairs(data.raw["damage-type"]) do
    if dmgType.name == "explosion" or dmgType.name == "physical" then goto continue end
    table.insert(data.raw["simple-entity-with-owner"]["kj_stargate_transferArea"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })
    table.insert(data.raw["assembling-machine"]["kj_dhd"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })
    ::continue::
end