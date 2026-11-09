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

data:extend({skyTile, star, radar})
