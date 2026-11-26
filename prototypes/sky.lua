local modname = "__kj_stargate__"
local chars = {}

for i = string.byte("A"), string.byte("S") do
    table.insert(chars, string.char(i))
end
for i = string.byte("a"), string.byte("s") do
    table.insert(chars, string.char(i))
end

local skyTile = table.deepcopy(data.raw.tile["empty-space"] or data.raw.tile["out-of-map"])
skyTile.name = "kj_sg_sky_tile"
skyTile.hidden = true
skyTile.autoplace = nil
skyTile.map_color = {r = 0.02, g = 0.02, b = 0.06}
skyTile.order = "z[kj-sky]"
skyTile.default_cover_tile = nil

local glyphBlueprints = {}
for i, char in ipairs(chars) do
    table.insert(glyphBlueprints, {
            type = "simple-entity",
            name = "kj_sg_glyph_"..char,
            icon = modname.."/graphics/glyphs/mask/"..string.format("%04d", i+1)..".png",
            icon_size = 256,
            flags = {"not-rotatable", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-upgradable", "no-copy-paste", "hide-alt-info", "not-selectable-in-game"},
            selection_box = {{-2, -2}, {2, 2}},
            localised_name = {"", {"starsign"}, " ", {"glyph_"..char}},
            localised_description = {"", {"starsign"}, " ", {"glyph_"..char}},
            hidden = true,
            picture = {
                size = 256,
                scale = 5.5/2,
                filename = modname.."/graphics/glyphs/mask/"..string.format("%04d", i+1)..".png",
                blend_mode = "additive",
            },
        }
    )
    table.insert(glyphBlueprints, {
            type = "item",
            name = "kj_sg_glyph_"..char,
            icon = modname.."/graphics/glyphs/mask/"..string.format("%04d", i+1)..".png",
            icon_size = 256,
            localised_name = {"", {"starsign"}, " ", {"glyph_"..char}},
            localised_description = {"", {"starsign"}, " ", {"glyph_"..char}},
            stack_size = 1,
            hidden = true,
            place_result = "kj_sg_glyph_"..char,
            auto_recycle = false,
        }
    )
end
data:extend(glyphBlueprints)

data:extend({
    {
        type = "radar",
        name = "kj_sg_sky_radar",
        icon = "__base__/graphics/icons/radar.png",
        flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-upgradable", "no-copy-paste", "hide-alt-info", "not-selectable-in-game"},
        max_health = 250,
        selectable_in_game = false,
        hidden = true,
        collision_mask = {layers = {}},
        energy_per_sector = "1J",
        max_distance_of_sector_revealed = 0,
        max_distance_of_nearby_sector_revealed = 1,
        connects_to_other_radars = false,
        is_military_target = false,
        energy_per_nearby_scan = "1J",
        energy_source = {type = "void"},
        energy_usage = "1W",
        pictures = {
            filename = "__core__/graphics/empty.png",
            priority = "low",
            width = 1,
            height = 1,
            direction_count = 1,
        },
    },
    {
        type = "animation",
        name = "kj_sg_star",
        layers = {
            {
                filename = modname.."/graphics/entities/star.png",
                priority = "high",
                size = 512,
                scale = 0.5,
                blend_mode = "additive",
                draw_as_glow = true,
                frame_count = 16,
                line_length = 4,
                animation_speed = 1,
                run_mode = "forward-then-backward",
            },
        }
    },
    {
        type = "lamp",
        name = "kj_sg_sky_star",
        icon = "__base__/graphics/icons/small-lamp.png",
        flags = {"placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-upgradable", "no-copy-paste", "not-rotatable"},
        hidden = true,
        max_health = 100,
        collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        collision_mask = {layers = {}},
        impact_category = "glass",
        energy_source = {type = "void"},
        energy_usage_per_tick = "5kW",
        darkness_for_all_lamps_on = 0.5,
        darkness_for_all_lamps_off = 0.3,
        glow_size = 6,
        glow_color_intensity = 1,
        glow_render_mode = "multiplicative",
        always_on = true,
        map_color = {r = 1, g = 1, b = 1},
        friendly_map_color = {r = 1, g = 1, b = 1},
        light = {intensity = 0.6, size = 6, color = {r = 0.8, g = 0.9, b = 1}},

        circuit_wire_max_distance = 40,
        circuit_connector = {
            points = {
                shadow = {
                    green = {0, 0},
                    copper= {0, 0},
                    red =   {0, 0},
                },
                wire = {
                    green = {0, 0},
                    copper= {0, 0},
                    red =   {0, 0},
                },
            },
            sprites = {
                led_blue = util.empty_sprite(),
                led_green = util.empty_sprite(),
                led_light = {intensity = 0, size = 0},
                led_red = util.empty_sprite(),
            },
        },
    },
    {
        type = "electric-energy-interface",
        name = "kj_sg_observatory",
        icon = "__space-exploration-graphics__/graphics/icons/telescope-xray.png",
        icon_size = 64,
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
skyTile})
