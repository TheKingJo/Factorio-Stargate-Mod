function initStorage()
    local names = {
        dhd = true,
        stargate = true,
        tasks = true,
        addresses = true,
        ignoredVehicles = true, --vehicles that were just teleported are ignored for some ticks so they dont teleport constantly back and forth
        autoGenGates = true,
        illegalCars = true,
    }
    local tasks = {
        activeGates = true,
        busyDhds = true, -- tracks the resets of dhd after x time
        eventHorizons = true,
        vehicles = true,
        players = true,
        delayedSounds = true,
        delayedTurnOffs = true,
        signaledGates = true,
    }
    for name, _ in pairs(names) do
        storage[name] = storage[name] or {}
    end
    for task, _ in pairs(tasks) do
        storage.tasks[task] = storage.tasks[task] or {}
    end

    local cars = prototypes.get_entity_filtered({{filter = "type", type = "car"}})
    for name, car in pairs(cars) do
        local collBox = car.collision_box
        if math.abs(collBox.left_top.x) + math.abs(collBox.right_bottom.x) > 3 then
            storage.illegalCars[name] = true
        end
        game.print("saas")
    end
    if kj_compat and kj_compat.wideCars then
        for _, name in pairs(kj_compat.wideCars) do
            storage.illegalCars[name] = true
        end
    end
    storage.illegalCars["heli-entity-_-"] = true
    storage.illegalCars["scout-heli-entity-_-"] = true
end

function OnLoad(e)
	if storage.stargate then
		for _, surface in pairs(storage.stargate) do
            for _, gate in pairs(surface) do
                setmetatable(gate, {__index = stargate})
            end
		end
	end
	if storage.dhd then
		for _, surface in pairs(storage.dhd) do
            for _, device in pairs(surface) do
                setmetatable(device, {__index = dhd})
            end
		end
	end

	util.mtMgr.OnLoad()
end

function OnInit(e)
    initStorage()
    for _, surface in pairs(game.surfaces) do
        addAddressToGlobal(surface, generateAdress(surface))
        --[[Chunk({
            position = {x = 0, y = 0},
            surface = surface
        })]]
    end
end
