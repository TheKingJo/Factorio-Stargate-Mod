data:extend({
    {
        type = "simple-entity",
        name = "kj_stargate",
        collision_box = {{-1.5, -0.5}, {1.5, 0.5}},
        selection_box = {{-1.5, -0.5}, {1.5, 0.5}},
		collision_mask = {layers = {}},
        minable = {mining_time = 1, result = "kj_stargate"},
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