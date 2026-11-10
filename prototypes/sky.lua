local modname = "__kj_stargate__"

local skyTile = table.deepcopy(data.raw.tile["empty-space"] or data.raw.tile["out-of-map"])
skyTile.name = "kj_sg_sky_tile"
skyTile.hidden = true
skyTile.autoplace = nil
skyTile.map_color = {r = 0.02, g = 0.02, b = 0.06}
skyTile.order = "z[kj-sky]"

local star = table.deepcopy(data.raw.lamp["small-lamp"])
star.name = "kj_sg_sky_star"
star.hidden = true
star.minable = nil
star.placeable_by = nil
star.next_upgrade = nil
star.fast_replaceable_group = nil
star.corpse = nil
star.dying_explosion = nil
star.flags = {"placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-upgradable", "no-copy-paste", "not-rotatable"}
star.collision_mask = {layers = {}}
star.energy_source = {type = "void"}
star.always_on = true
star.circuit_wire_max_distance = 40
star.map_color = {r = 1, g = 1, b = 1}
star.friendly_map_color = {r = 1, g = 1, b = 1}
star.light = {intensity = 0.6, size = 6, color = {r = 0.8, g = 0.9, b = 1}}

local radar = table.deepcopy(data.raw.radar["radar"])
radar.name = "kj_sg_sky_radar"
radar.hidden = true
radar.minable = nil
radar.placeable_by = nil
radar.next_upgrade = nil
radar.fast_replaceable_group = nil
radar.corpse = nil
radar.dying_explosion = nil
radar.flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-upgradable", "no-copy-paste", "hide-alt-info", "not-selectable-in-game"}
radar.selectable_in_game = false
radar.selection_box = nil
radar.collision_mask = {layers = {}}
radar.energy_source = {type = "void"}
radar.energy_usage = "1W"
radar.energy_per_sector = "1J"
radar.energy_per_nearby_scan = "1J"
radar.max_distance_of_sector_revealed = 0
radar.max_distance_of_nearby_sector_revealed = 1
radar.connects_to_other_radars = false
radar.is_military_target = false
radar.pictures = {
    filename = "__core__/graphics/empty.png",
    priority = "low",
    width = 1,
    height = 1,
    direction_count = 1,
}
radar.integration_patch = nil
radar.water_reflection = nil
radar.working_sound = nil
radar.radius_minimap_visualisation_color = nil
radar.circuit_connector = nil
radar.circuit_wire_max_distance = 0

local observatory = table.deepcopy(data.raw.accumulator["accumulator"])


local observatoryItem = table.deepcopy(data.raw.item["accumulator"])
observatoryItem.name = "kj_sg_observatory"
observatoryItem.place_result = "kj_sg_observatory"
observatoryItem.subgroup = "transport"
observatoryItem.order = "5"
local observatoryRecipe = {
    type = "recipe",
    name = "kj_sg_observatory",
    enabled = true,
    energy_required = 0.1,
    ingredients = {},
    results = {{type = "item", name = "kj_sg_observatory", amount = 1}},
}

data:extend({
    {
        type = "electric-energy-interface",
        name = "kj_sg_observatory",
        icon = modname.."/graphics/s_icon.png",
        icon_size = 128,
        dying_explosion = "big-explosion",
        collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
        selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
        minable = {
            mining_time = 5,
            results = {
                {type = "item", name = "kj_sg_observatory", amount = 1},
            }
        },
        flags = {"not-on-map", "placeable-neutral", "not-flammable"},
        max_health = 500,
        is_military_target  = false,
        gui_mode = "all",
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            buffer_capacity = "10MJ",
            drain = "10MW",
            input_flow_limit = "100MW",
            output_flow_limit = "100W",
        },
        animation = {
            layers =
            {
                {
                    filename = "__space-exploration-graphics-4__/graphics/entity/telescope-xray/telescope-xray.png",
                    priority = "high",
                    width = 360,
                    height = 404,
                    frame_count = 1,
                    line_length = 8,
                    shift = util.by_pixel(6, -13),
                    animation_speed = 1,
                    scale = 0.5,
                    y = 404*2,
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-south.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    shift = {0, 3},
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    shift = {3, 0},
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    shift = util.by_pixel(-3*32+1, 1),
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west-shadow.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    shift = util.by_pixel(-3*32+1, 1),
                    draw_as_shadow = true
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east-shadow.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    shift = {3, 0},
                    draw_as_shadow = true
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-south-shadow.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    shift = {0, 3},
                    draw_as_shadow = true,
                },
                {
                    draw_as_shadow = true,
                    filename = "__space-exploration-graphics-4__/graphics/entity/telescope-xray/telescope-xray-shadow.png",
                    priority = "high",
                    width = 464,
                    height = 278,
                    frame_count = 1,
                    line_length = 8,
                    shift = util.by_pixel(33, 10),
                    animation_speed = 1,
                    scale = 0.5,
                    y = 278*2,
                },
            },
        }
    },
skyTile, star, radar, observatory, observatoryItem, observatoryRecipe})
