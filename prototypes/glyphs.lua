local modname = "__kj_stargate__"
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
            subgroup = "kj_dhd_glyphs",
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
        type = "item-group",
        name = "kj_dhd_glyphs",
        icon = modname.."/graphics/entities/dhd/icon.png",
        icon_size = 128,
        order = "y-dhd",
    },
    {
        type = "item-subgroup",
        name = "kj_dhd_glyphs",
        group = "kj_dhd_glyphs",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_connect",
        icon = modname.."/graphics/glyphs/connect.png",
        icon_size = 128,
        order = "z-connect",
        subgroup = "kj_dhd_glyphs",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_1",
        icon = modname.."/graphics/glyphs/0001.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 1"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 1"},
        order = "poo-1",
        subgroup = "kj_dhd_glyphs",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_2",
        icon = modname.."/graphics/glyphs/0040.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 2"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 2"},
        order = "poo-1",
        subgroup = "kj_dhd_glyphs",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_3",
        icon = modname.."/graphics/glyphs/0041.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 3"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 3"},
        order = "poo-1",
        subgroup = "kj_dhd_glyphs",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_4",
        icon = modname.."/graphics/glyphs/0042.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 4"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 4"},
        order = "poo-1",
        subgroup = "kj_dhd_glyphs",
    },
    {
        type = "virtual-signal",
        name = "kj_sg_glyph_poo_5",
        icon = modname.."/graphics/glyphs/0043.png",
        icon_size = 128,
        localised_name = {"", {"virtual-signal-name.kj_sg_glyph_poo"}, " 5"},
        localised_description = {"", {"virtual-signal-description.kj_sg_glyph_poo"}, " 5"},
        order = "poo-1",
        subgroup = "kj_dhd_glyphs",
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