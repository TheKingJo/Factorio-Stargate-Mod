data:extend({
	{
		type = "technology",
		name = "kj_stargate",
        icon = "__kj_stargate__/graphics/icon.png",
        icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "kj_stargate_placement",
			},
		},
		research_trigger = {
			type = "mine-entity",
			entities = {
                "kj_stargate_auto_gen",
            }
		},
	},
	{
		type = "technology",
		name = "kj_stargate_s",
        icon = "__kj_stargate__/graphics/s_icon.png",
        icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "kj_stargate_signaled_placement",
			},
		},
		research_trigger = {
			type = "build-entity",
			entity = "kj_stargate_placement",
		},
		prerequisites = {"kj_stargate", "circuit-network", "lamp", "steel-processing"},
	},
	{
		type = "technology",
		name = "kj_stargate_iris",
        icon = "__kj_stargate__/graphics/s_gate_iris_icon.png",
        icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "kj_stargate_signaled_iris_placement",
			},
			{
				type = "unlock-recipe",
				recipe = "kj_stargate_iris",
			},
		},
		research_trigger = {
			type = "craft-item",
			item = "tungsten-plate",
			count = 1000,
		},
		prerequisites = {"kj_stargate_s", "tungsten-steel", "holmium-processing"},
	},
})