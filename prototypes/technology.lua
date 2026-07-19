data:extend({
	{
		type = "technology",
		name = "kj_stargate",
        icon = "__kj_stargate__/graphics/entities/stargate/icon.png",
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
        icon = "__kj_stargate__/graphics/entities/stargate/s_icon.png",
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
})