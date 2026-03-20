data:extend({
    {
        type = "item-with-entity-data",
        name = "kj_stargate",
        icon = data.raw["item"]["iron-plate"].icon,
        icon_size = data.raw["item"]["iron-plate"].icon_size,
        subgroup = "transport",
        order = "0",
        --inventory_move_sound = item_sounds.vehicle_inventory_move,
        --pick_sound = item_sounds.vehicle_inventory_pickup,
        --drop_sound = item_sounds.vehicle_inventory_move,
        place_result = "kj_stargate",
        stack_size = 1,
        weight = 1000 * 1000,
    },
})