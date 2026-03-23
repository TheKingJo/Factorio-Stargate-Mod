data:extend({
    {
        type = "simple-entity",
        name = "kj_stargate_placement",
        icon = "__kj_stargate__/graphics/entities/stargate/icon.png",
        icon_size = 128,
        collision_box = {{-3.9, -2.4}, {3.9, 2.4}},
        selection_box = {{-4,   -2.5}, {4,   2.5}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
        picture = {
            layers = {
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, -1.5},
                    scale = 0.5,
                    filename = "__kj_stargate__/graphics/entities/stargate/gate.png",
                },
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, -1.5},
                    scale = 0.5,
                    draw_as_shadow = true,
                    filename = "__kj_stargate__/graphics/entities/stargate/gate_shadow.png",
                },
            }
        }
    },
    {
        type = "simple-entity",
        name = "kj_stargate_base",
        icon = "__kj_stargate__/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        --collision_box = {{-1.5, -0.5}, {1.5, 0.5}},
        --selection_box = {{-1.5, -0.5}, {1.5, 0.5}},
        render_layer = "object-under",
		collision_mask = {layers = {}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
        picture = {
            layers = {
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, -1.5},
                    scale = 0.5,
                    filename = "__kj_stargate__/graphics/entities/stargate/gate.png",
                },
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, -1.5},
                    scale = 0.5,
                    draw_as_shadow = true,
                    filename = "__kj_stargate__/graphics/entities/stargate/gate_shadow.png",
                },
                --[[{
                    width = 704,
                    height = 704,
                    shift = {1.25, -1.5},
                    scale = 0.5,
                    blend_mode = "additive",
                    draw_as_glow = true,
                    filename = "__kj_stargate__/graphics/entities/stargate/gate_light.png",
                },]]
            }
        }
    },
    {
        type = "simple-entity",
        name = "kj_stargate_transferArea",
        icon = "__kj_stargate__/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        collision_mask = {layers = {}},
        collision_box = {{-1.5, -0.3}, {1.5, 0.3}},
        selection_box = {{-1.5, -0.3}, {1.5, 0.3}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
    },
    {
        type = "simple-entity",
        name = "kj_stargate_colliderVert",
        icon = "__kj_stargate__/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        collision_box = {{-0.5, -1.5}, {0.5, 2}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
    },
    {
        type = "simple-entity",
        name = "kj_stargate_colliderHori",
        icon = "__kj_stargate__/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        collision_box = {{-3, -0.225}, {3, 0.225}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
    },
    {
        type = "simple-entity-with-force",
        name = "kj_stargate_colliderDiag",
        icon = "__kj_stargate__/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable", "building-direction-16-way"},
        collision_box = {{-1, -0.1}, {1, 0.1}},
        is_military_target  = false,
        minable = {mining_time = 1, result = "kj_stargate_placement"},
    },


    {
        type = "electric-energy-interface",
        name = "kj_dhd",
        collision_box = {{-1, -1}, {1, 1}},
        selection_box = {{-1, -1}, {1, 1}},
        minable = {mining_time = 1, result = "kj_dhd"},
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            buffer_capacity = "5MJ",
            drain = "1kW",
            input_flow_limit = "300kW",
            output_flow_limit = "300kW",
        },
        animations = {
            north = {
                layers = {
                    {
                        width = 576/2,
                        height = 576/2,
                        x = 0,
                        y = 576/2,
                        frame_count = 1,
                        shift = {0, 0.5},
                        scale = 0.5,
                        animation_speed = 1,
                        max_advance = 1,
                        stripes =
                        {
                            {
                                filename = "__kj_stargate__/graphics/entities/dhd/dhd.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                    {
                        width = 576/2,
                        height = 576/2,
                        x = 0,
                        y = 576/2,
                        frame_count = 1,
                        shift = {0, 0.5},
                        scale = 0.5,
                        animation_speed = 1,
                        max_advance = 1,
                        draw_as_shadow = true,
                        stripes =
                        {
                            {
                                filename = "__kj_stargate__/graphics/entities/dhd/dhd_shadow.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                }
            },
            east = {
                layers = {
                    {
                        width = 576/2,
                        height = 576/2,
                        x = 576/2,
                        y = 576/2,
                        frame_count = 1,
                        shift = {0, 0.5},
                        scale = 0.5,
                        animation_speed = 1,
                        max_advance = 1,
                        stripes =
                        {
                            {
                                filename = "__kj_stargate__/graphics/entities/dhd/dhd.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                    {
                        width = 576/2,
                        height = 576/2,
                        x = 576/2,
                        y = 576/2,
                        frame_count = 1,
                        shift = {0, 0.5},
                        scale = 0.5,
                        animation_speed = 1,
                        max_advance = 1,
                        draw_as_shadow = true,
                        stripes =
                        {
                            {
                                filename = "__kj_stargate__/graphics/entities/dhd/dhd_shadow.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                }
            },
            south = {
                layers = {
                    {
                        width = 576/2,
                        height = 576/2,
                        x = 0,
                        y = 0,
                        frame_count = 1,
                        shift = {0, 0.5},
                        scale = 0.5,
                        animation_speed = 1,
                        max_advance = 1,
                        stripes =
                        {
                            {
                                filename = "__kj_stargate__/graphics/entities/dhd/dhd.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                    {
                        width = 576/2,
                        height = 576/2,
                        x = 0,
                        y = 0,
                        frame_count = 1,
                        shift = {0, 0.5},
                        scale = 0.5,
                        animation_speed = 1,
                        max_advance = 1,
                        draw_as_shadow = true,
                        stripes =
                        {
                            {
                                filename = "__kj_stargate__/graphics/entities/dhd/dhd_shadow.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                }
            },
            west = {
                layers = {
                    {
                        width = 576/2,
                        height = 576/2,
                        x = 576/2,
                        y = 0,
                        frame_count = 1,
                        shift = {0, 0.5},
                        scale = 0.5,
                        animation_speed = 1,
                        max_advance = 1,
                        stripes =
                        {
                            {
                                filename = "__kj_stargate__/graphics/entities/dhd/dhd.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                    {
                        width = 576/2,
                        height = 576/2,
                        x = 576/2,
                        y = 0,
                        frame_count = 1,
                        shift = {0, 0.5},
                        scale = 0.5,
                        animation_speed = 1,
                        max_advance = 1,
                        draw_as_shadow = true,
                        stripes =
                        {
                            {
                                filename = "__kj_stargate__/graphics/entities/dhd/dhd_shadow.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                }
            },
        }
    }
})


--char table
local chars = {"z"}
for i = string.byte("A"), string.byte("S") do
    table.insert(chars, string.char(i))
end
for i = string.byte("a"), string.byte("s") do
    table.insert(chars, string.char(i))
end
for i, char in ipairs(chars) do
    if i == 1 then
        goto continue
    end
    data:extend({
        {
            type = "virtual-signal",
            name = "kj_sg_glyph_"..char,
            icon = "__kj_stargate__/graphics/glyphs/"..string.format("%04d", i)..".png",
            icon_size = 128,
            localised_name = {"", {"virtual-signal-name.kj_sg_glyph"}, " ", tostring(i-1)},
            localised_description = {"", {"virtual-signal-description.kj_sg_glyph"}, tostring(i-1)},
            order = tostring(string.format("%03d", i-1)),
        },
    })
    ::continue::
end

data:extend({
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poe_1",
        icon = "__kj_stargate__/graphics/glyphs/0001.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poe"}, " 1"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poe"}, " 1"},
        order = "poe-1",
    },
})