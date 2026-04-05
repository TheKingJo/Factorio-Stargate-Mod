local modname = "__kj_stargate__"
data:extend({
    {
        type = "simple-entity",
        name = "kj_stargate_auto_gen",
        icon = modname.."/graphics/entities/stargate/icon.png",
        icon_size = 128,
        collision_box = {{-2, -2}, {2, 2}},
        selection_box = {{-2, -2}, {2, 2}},
        minable = {
            mining_time = 20,
            results = {
                {type = "item", name = "kj_stargate_placement", amount = 1},
                {type = "item", name = "kj_dhd", amount = 1},
            }
        },
        picture = {
            layers = {
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, -1.5},
                    scale = 0.5,
                    filename = modname.."/graphics/entities/stargate/gate.png",
                },
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, -1.5},
                    scale = 0.5,
                    draw_as_shadow = true,
                    filename = modname.."/graphics/entities/stargate/gate_shadow.png",
                },
            }
        }
    },
    {
        type = "simple-entity",
        name = "kj_stargate_placement",
        icon = modname.."/graphics/entities/stargate/icon.png",
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
                    filename = modname.."/graphics/entities/stargate/gate.png",
                },
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, -1.5},
                    scale = 0.5,
                    draw_as_shadow = true,
                    filename = modname.."/graphics/entities/stargate/gate_shadow.png",
                },
            }
        },
        surface_conditions = {
            {
                property = "gravity",
                min = 0.1,
            }
        },
    },
    {
        type = "simple-entity",
        name = "kj_stargate_base",
        icon = modname.."/graphics/entities/stargate/icon.png",
        hidden = true,
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        --collision_box = {{-1.5, -0.5}, {1.5, 0.5}},
        --selection_box = {{-1.5, -0.5}, {1.5, 0.5}},
        --render_layer = "object-under",
		collision_mask = {layers = {}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
        picture = {
            layers = {
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, 0.5},
                    scale = 0.5,
                    filename = modname.."/graphics/entities/stargate/gate.png",
                },
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, 0.5},
                    scale = 0.5,
                    draw_as_shadow = true,
                    filename = modname.."/graphics/entities/stargate/gate_shadow.png",
                },
            }
        }
    },
    {
        type = "simple-entity",
        name = "kj_stargate_transferArea",
        icon = modname.."/graphics/entities/stargate/icon.png",
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
        hidden = true,
        icon = modname.."/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        collision_box = {{-0.5, -1.5}, {0.5, 2}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
    },
    {
        type = "simple-entity",
        name = "kj_stargate_colliderHori1",
        hidden = true,
        icon = modname.."/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        collision_box = {{-3, -0.225}, {3, 0.225}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
    },
    {
        type = "simple-entity",
        name = "kj_stargate_colliderHori2",
        hidden = true,
        icon = modname.."/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        collision_box = {{-0.75, -0.1}, {0.75, 0.1}},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
    },
    {
        type = "simple-entity-with-force",
        name = "kj_stargate_colliderDiag",
        hidden = true,
        icon = modname.."/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable", "building-direction-16-way"},
        collision_box = {{-1, -0.1}, {1, 0.1}},
        is_military_target  = false,
        minable = {mining_time = 1, result = "kj_stargate_placement"},
    },
    {
        type = "simple-entity-with-force",
        name = "kj_stargate_ambientSound",
        hidden = true,
        icon = modname.."/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        minable = {mining_time = 1, result = "kj_stargate_placement"},
		collision_mask = {layers = {}},
        is_military_target  = false,
        ambient_sounds = {
            radius = 15,
            min_entity_count = 1,
            sound = {
		        filename = modname.."/sounds/gate_puddle.ogg",
                volume = 1,
            }
        },
    },
    {
        type = "electric-energy-interface",
        name = "kj_stargate_eventHorizon_ent",
        collision_box = {{-1, -1}, {1, 1}},
		collision_mask = {layers = {}},
        icon = modname.."/graphics/entities/stargate/icon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "placeable-off-grid", "not-flammable"},
        gui_mode = "none",
        energy_source = {
            render_no_power_icon = false,
            type = "electric",
            usage_priority = "secondary-input",
            buffer_capacity = "0J",
            drain = "0W",
            input_flow_limit = "0W",
            output_flow_limit = "0W",
        },
        continuous_animation = true,
        animation = {
            layers = {
                --[[{
                    width = 704,
                    height = 704,
                    shift = {1.25, 0.49},
                    scale = 0.5,
                    frame_count = 64,
                    line_length = 8,
                    filename = modname.."/graphics/entities/stargate/eventHorizon.png",
                },]]
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, 0.49},
                    scale = 0.5,
                    frame_count = 64,
                    stripes = {
                        {
                            filename = modname.."/graphics/entities/stargate/eventHorizon.png",
                            height_in_frames = 8,
                            width_in_frames = 8,
                        },
                    },
                },
                {
                    width = 704,
                    height = 704,
                    shift = {1.25, 0.49},
                    scale = 0.5,
                    frame_count = 64,
                    blend_mode = "additive",
                    draw_as_glow = true,
                    stripes = {
                        {
                            filename = modname.."/graphics/entities/stargate/eventHorizon_light.png",
                            height_in_frames = 8,
                            width_in_frames = 8,
                        },
                    },
                },
            },
        },
    },
    {
        type = "animation",
        name = "kj_stargate_chevrons",
        layers = {
            {
                width = 704,
                height = 704,
                shift = {1.25, 0.5},
                scale = 0.5,
                frame_count = 8,
                line_length = 8,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/stargate/chevron_light.png",
            },
        }
    },
    --[[{
        type = "animation",
        name = "kj_stargate_eventHorizon",
        layers = {
            {
                width = 704,
                height = 704,
                shift = {1.25, 0.5},
                scale = 0.5,
                frame_count = 1,
                filename = modname.."/graphics/entities/stargate/eventHorizon.png",
            },
            {
                width = 704,
                height = 704,
                shift = {1.25, 0.5},
                scale = 0.5,
                frame_count = 1,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/stargate/gate_light.png",
            },
        }
    },]]
})

data:extend({
    {
        type = "projectile",
        name = "kj_stargate_woosh",
        flags = {"not-on-map"},
        hidden = true,
        acceleration = 0.005,
        action =
        {
            {
                type = "direct",
                action_delivery =
                {
                    type = "instant",
                    target_effects =
                    {
                        {
                            type = "create-smoke",
                            show_in_tooltip = true,
                            entity_name = "kj_woosh_cloud",
                            initial_height = 0
                        },
                    }
                }
            }
        },
    },
    {
        type = "smoke-with-trigger",
        name = "kj_woosh_cloud",
        flags = {"not-on-map"},
        hidden = true,
        affected_by_wind = false,
        cyclic = true,
        duration = 60 * 2,
        fade_away_duration = 0,
        spread_duration = 0,
        action_cooldown = 1,
        action =
        {
            type = "direct",
            action_delivery =
            {
                type = "instant",
                target_effects =
                {
                    type = "nested-result",
                    action =
                    {
                        type = "area",
                        radius = 2.5,
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "damage",
                                    damage = { amount = 999999, type = "electric"}
                                },
                                {
                                    type = "damage",
                                    damage = { amount = 999999, type = "impact"}
                                },
                                {
                                    type = "damage",
                                    damage = { amount = 999999, type = "fire"}
                                },
                                {
                                    type = "damage",
                                    damage = { amount = 999999, type = "physical"}
                                },
                                {
                                    type = "damage",
                                    damage = { amount = 999999, type = "poison"}
                                },
                                {
                                    type = "damage",
                                    damage = { amount = 999999, type = "acid"}
                                },
                                {
                                    type = "damage",
                                    damage = { amount = 999999, type = "laser"}
                                },
                            }
                        }
                    }
                }
            }
        },
    },
})

data:extend({
    {
        type = "electric-energy-interface",
        name = "kj_dhd",
        collision_box = {{-1, -1}, {1, 1}},
        selection_box = {{-1, -1}, {1, 1}},
        minable = {mining_time = 1, result = "kj_dhd"},
        gui_mode = "all",
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
                                filename = modname.."/graphics/entities/dhd/dhd.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                    {
                        size = 576/2,
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
                                filename = modname.."/graphics/entities/dhd/dhd_shadow.png",
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
                        size = 576/2,
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
                                filename = modname.."/graphics/entities/dhd/dhd.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                    {
                        size = 576/2,
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
                                filename = modname.."/graphics/entities/dhd/dhd_shadow.png",
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
                        size = 576/2,
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
                                filename = modname.."/graphics/entities/dhd/dhd.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                    {
                        size = 576/2,
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
                                filename = modname.."/graphics/entities/dhd/dhd_shadow.png",
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
                        size = 576/2,
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
                                filename = modname.."/graphics/entities/dhd/dhd.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                    {
                        size = 576/2,
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
                                filename = modname.."/graphics/entities/dhd/dhd_shadow.png",
                                width_in_frames = 2,
                                height_in_frames = 2,
                            },
                        }
                    },
                }
            },
        },
        surface_conditions = {
            {
                property = "gravity",
                min = 0.1,
            }
        },
    },
    {
        type = "sprite",
        name = "kj_stargate_dhd_button_8",--north
        layers = {
            {
                size = 288,
                shift = {0, 0.5},
                scale = 0.5,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/dhd/dhd_button_light.png",
            },
        }
    },
    {
        type = "sprite",
        name = "kj_stargate_dhd_button_12",--east
        layers = {
            {
                size = 288,
                shift = {0, 0.5},
                scale = 0.5,
                x = 288,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/dhd/dhd_button_light.png",
            },
        }
    },
    {
        type = "sprite",
        name = "kj_stargate_dhd_button_0",--south
        layers = {
            {
                size = 288,
                shift = {0, 0.5},
                scale = 0.5,
                y = 288,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/dhd/dhd_button_light.png",
            },
        }
    },
    {
        type = "sprite",
        name = "kj_stargate_dhd_button_4",--west
        layers = {
            {
                size = 288,
                shift = {0, 0.5},
                scale = 0.5,
                x = 288,
                y = 288,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/dhd/dhd_button_light.png",
            },
        }
    },

    {
        type = "animation",
        name = "kj_stargate_dhd_8",--north
        layers = {
            {
                size = 288,
                shift = {0, 0.5},
                scale = 0.5,
                frame_count = 40,
                line_length = 8,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/dhd/dhd_light_0.png",
            },
        }
    },
    {
        type = "animation",
        name = "kj_stargate_dhd_12",--east
        layers = {
            {
                size = 288,
                shift = {0, 0.5},
                scale = 0.5,
                frame_count = 40,
                line_length = 8,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/dhd/dhd_light_1.png",
            },
        }
    },
    {
        type = "animation",
        name = "kj_stargate_dhd_0",--south
        layers = {
            {
                size = 288,
                shift = {0, 0.5},
                scale = 0.5,
                frame_count = 40,
                line_length = 8,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/dhd/dhd_light_2.png",
            },
        }
    },
    {
        type = "animation",
        name = "kj_stargate_dhd_4",--west
        layers = {
            {
                size = 288,
                shift = {0, 0.5},
                scale = 0.5,
                frame_count = 40,
                line_length = 8,
                blend_mode = "additive",
                draw_as_glow = true,
                filename = modname.."/graphics/entities/dhd/dhd_light_3.png",
            },
        }
    },


    {
        type = "tile",
        name = "kj_stargate_slowDownTile",
        hidden = true,
        walking_speed_modifier = 0.5,
        vehicle_friction_modifier = 0.5,
        collision_mask = {layers={ground_tile=true}},
        map_color={0, 0, 0},
        layer = 0,
        variants = {
            material_background =
            {
                picture = "__core__/graphics/empty.png",
                count = 1,
                scale = 1
            },
            empty_transitions = true
        },
    },
})


--char table
local chars = {}
for i = string.byte("A"), string.byte("S") do
    table.insert(chars, string.char(i))
end
for i = string.byte("a"), string.byte("s") do
    table.insert(chars, string.char(i))
end
for i, char in ipairs(chars) do
    data:extend({
        {
            type = "virtual-signal",
            name = "kj_sg_glyph_"..char,
            icon = modname.."/graphics/glyphs/"..string.format("%04d", i+1)..".png",
            icon_size = 128,
            localised_name = {"", {"virtual-signal-name.kj_sg_glyph"}, " ", tostring(i-1)},
            localised_description = {"", {"virtual-signal-description.kj_sg_glyph"}, tostring(i-1)},
            order = tostring(string.format("%03d", i-1)),
        },
        {
            type = "sprite",
            name = "kj_sg_glyph_"..char,
            filename = modname.."/graphics/glyphs/"..string.format("%04d", i+1)..".png",
            size = 128,
        },
    })
end

data:extend({
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_1",
        icon = modname.."/graphics/glyphs/0001.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 1"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 1"},
        order = "poo-1",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_2",
        icon = modname.."/graphics/glyphs/0040.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 2"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 2"},
        order = "poo-1",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_3",
        icon = modname.."/graphics/glyphs/0041.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 3"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 3"},
        order = "poo-1",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_4",
        icon = modname.."/graphics/glyphs/0042.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 4"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 4"},
        order = "poo-1",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_5",
        icon = modname.."/graphics/glyphs/0043.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 5"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 5"},
        order = "poo-1",
    },
})
data:extend({
    {
        type = "sprite",
        name = "kj_sg_glyph_poo_1",
        filename = modname.."/graphics/glyphs/0001.png",
        size = 128,
    },
    {
        type = "sprite",
        name = "kj_sg_glyph_poo_2",
        filename = modname.."/graphics/glyphs/0040.png",
        size = 128,
    },
    {
        type = "sprite",
        name = "kj_sg_glyph_poo_3",
        filename = modname.."/graphics/glyphs/0041.png",
        size = 128,
    },
    {
        type = "sprite",
        name = "kj_sg_glyph_poo_4",
        filename = modname.."/graphics/glyphs/0042.png",
        size = 128,
    },
    {
        type = "sprite",
        name = "kj_sg_glyph_poo_5",
        filename = modname.."/graphics/glyphs/0043.png",
        size = 128,
    },


    {
        type = "sprite",
        name = "kj_sg_glyph_connect",
        filename = modname.."/graphics/glyphs/connect.png",
        size = 128,
    },
})