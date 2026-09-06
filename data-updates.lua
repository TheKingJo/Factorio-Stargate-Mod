for _, dmgType in pairs(data.raw["damage-type"]) do
    if dmgType.name == "explosion" or dmgType.name == "physical" then goto continue end

    table.insert(data.raw["electric-pole"]["kj_stargate_pole_visible_right"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })
    table.insert(data.raw["electric-pole"]["kj_stargate_pole_visible_left"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })

    table.insert(data.raw["simple-entity-with-owner"]["kj_stargate_entity"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })
    table.insert(data.raw["electric-energy-interface"]["kj_stargate_entity_signaled"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })
    table.insert(data.raw["assembling-machine"]["kj_dhd"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })

    table.insert(data.raw["simple-entity-with-owner"]["kj_stargate_auto_gen"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })
    table.insert(data.raw["simple-entity-with-owner"]["kj_dhd_auto_gen"].resistances, {
        type = dmgType.name,
        decrease = 0,
        percent  = 100
    })
    ::continue::
end