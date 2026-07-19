data:extend({
	{
		type = "recipe",
		name = "kj_stargate_signaled_placement",
		enabled = true,
		energy_required = 0.1,
		ingredients = {
            {type = "item", name = "kj_stargate", amount = 1},
            {type = "item", name = "steel-plate", amount = 25},
            {type = "item", name = "iron-stick",  amount = 50},
            {type = "item", name = "iron-plate",  amount = 50},
            {type = "item", name = "copper-cable",amount = 50},
            {type = "item", name = "small-lamp",  amount = 10},
        },
		results = {{type = "item", name = "kj_stargate_signaled_placement", amount = 1}},
	},
	{
		type = "recipe",
		name = "kj_stargate_placement",
		enabled = true,
		energy_required = 0.1,
		ingredients = {
            {type = "item", name = "kj_stargate", amount = 1},
            {type = "item", name = "stone", amount = 1000},
        },
		results = {{type = "item", name = "kj_stargate_placement", amount = 1}},
	},
	{
		type = "recipe",
		name = "kj_dhd",
		enabled = true,
		energy_required = 0.1,
		ingredients = {
            --{type = "item", name = "iron-plate", amount = 1},
        },
		results = {{type = "item", name = "kj_dhd", amount = 1}},
	},
})