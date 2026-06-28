stargate = {
    Initialize = function(self)
    end,

	Connect = function(thisGate, otherGate)
        if otherGate == nil then return end
        if otherGate.destination ~= nil then --other gate has connection
            if thisGate.dhd then
                thisGate.dhd:ResetGlyphs()
                thisGate.dhd:CloseGUIs()
            end
            util.playSoundOnSurface(thisGate.entity.surface, thisGate.entity.position, "kj_stargate_fail")
        else
            if thisGate.destination ~= nil then
                thisGate:Disconnect()
            end
            activateGate(thisGate)
            activateGate(otherGate)
            thisGate.destination = otherGate
            otherGate.destination = thisGate

            if otherGate.dhd then
                otherGate.dhd:FetchAddress(thisGate)
                otherGate.dhd:SetGlyphs()
            end

            storage.tasks.activeGates[thisGate.id] = {tick = game.tick + 20*60, maxTick = game.tick + 60*60, stargate = thisGate}

            --game.print("Gates connected: "..thisGate.id.."|"..otherGate.id)
        end
	end,

    Disconnect = function(self, override)
        local dest = self.destination
        if dest then
            deactivateGate(self, override)
            deactivateGate(dest, override)

            storage.tasks.activeGates[self.id] = nil
            --game.print("Gates disconnected: "..self.id.."|"..dest.id)
        end
    end,

    Reset = function(self)
        if self.destination == nil then
            self.chevrons.animation_offset = 0
        end
    end,
}

dhd = {
    Initialize = function(self)
        rendering.draw_animation{
            animation = "kj_stargate_dhd_"..self.entity.direction,
            animation_speed = 40/60,
            time_to_live = 60,
            target = self.entity.position,
            surface = self.entity.surface,
            render_layer = "object",
        }
        util.playSoundOnSurface(self.entity.surface, self.entity.position, "kj_stargate_dhd_connect", 1)
        if self.stargate.destination and self.stargate.active then
            self:SetButtonLight(true)
            self:FetchAddress(self.stargate.destination)
            self:SetGlyphs()
        end
    end,

    SetButtonLight = function(self, status)
        if status == true then
            self.buttonLight = rendering.draw_sprite{
                sprite = "kj_stargate_dhd_button_"..self.entity.direction,
                target = self.entity.position,
                surface = self.entity.surface,
                render_layer = "object",
            }
        else
            if self.buttonLight then self.buttonLight.destroy() end
        end
    end,

    FetchAddress = function(self, otherGate)
        local sName = otherGate.entity.surface.name
        self.address, self.addressLetters = util.lettersFromAddress(storage.addresses[sName], "poo_"..poo[sName], "poo_"..poo[self.entity.surface.name])
        --we do it this way (obv) so we display the address of the contrary gate

        --self.address = table.deepcopy(otherGate.dhd.address)
        --self.address[7] = "poo_"..poo[self.entity.surface.name]
        --self.addressLetters = table.deepcopy(otherGate.dhd.addressLetters)
        --self.addressLetters["poo_"..poo[self.entity.surface.name]] = true
    end,

    SetGlyphs = function(self)
        for i, glyph in ipairs(self.glyphs) do
            glyph.animation_offset = charLookup[self.address[i]]
        end
    end,

    ResetGlyphs = function(self)
        for _, glyph in pairs(self.glyphs) do
            glyph.animation_offset = 0
        end
        self.address = {}
        self.addressLetters = {}
    end,


    GetAddress = function(self)
        return table.concat(self.address)
    end,

	Connect = function(self, dhdSurface)
        --if string exists, then connect, otherwise empty table and make fail sound
        local selfAddress = self:GetAddress()
        local result = false
        local surface
        for s, address in pairs(storage.addresses) do
            if selfAddress == address.."poo_"..(poo[dhdSurface] or "") then
                surface = s
                result = true
            end
        end

        if dhdSurface == surface then result = false end --cant connect to same surface
        if storage.stargate[surface] == nil then result = false end --no gates on that surface
        --i have decided to allow multiple gate connections between surf a and b because it is canon

        if result == true then
            --game.print("omg we found a connection!")
            self.stargate:Connect(findRandomGateOnSurface(surface))
        else
            if self.stargate then
                if self.stargate.destination == nil then
                    self.stargate.chevrons.animation_offset = 0
                end
                util.playSoundOnSurface(self.stargate.entity.surface, self.stargate.entity.position, "kj_stargate_fail")
            else
                util.playSoundOnSurface(self.entity.surface, self.entity.position, "kj_stargate_fail")
            end
            --game.print("no gate with that address. emptying ram")
            self:ResetGlyphs()
            self:CloseGUIs()
        end
	end,

    Disconnect = function(self)
        self.stargate:Disconnect()
    end,

    TrackIdling = function(self)
        storage.tasks.busyDhds[self.id] = {tick = game.tick + 20*60, dhd = self}
    end,

    OpenedGUI = function(self, glyphTableUI)
        self.openedUIs = self.openedUIs or {}
        table.insert(self.openedUIs, glyphTableUI)
    end,

    CloseGUIs = function(self)
        if self.openedUIs == nil then return end
        for _, GUI in ipairs(self.openedUIs) do
            if GUI.valid then
                GUI.parent.parent.parent.parent.parent.destroy()
            end
        end
    end,

    Reset = function(self)
        self.entity.minable_flag = true
        self:SetButtonLight(false)
        self:CloseGUIs()
        if self.address then
            self:ResetGlyphs()
        end
    end,
}

function deactivateGate(gate, override)
    if gate.dhd then
        gate.dhd:Reset()
    end
    gate.chevrons.animation_offset = 0
    gate.childs.soundEnt.destroy()
    if gate.animation then
        gate.animation.destroy()
    end
    gate.entity.minable_flag = true
    gate.active = false
    --gate.safeToTravel = false
    --gate.destination = nil
    if override then
        gate.safeToTravel = false
        gate.destination = nil
        storage.tasks.eventHorizons[gate.id] = nil
    else
        util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_close")
        gate.entity.surface.create_entity {
            name = "kj_stargate_eventHorizon_short",
            position = util.vector2Add(gate.entity.position, {x = 0, y = 0.8}),
        }
        gate.entity.surface.create_entity {
            name = "kj_stargate_eventHorizon_woosh_backward",
            position = util.vector2Add(gate.entity.position, {x = 0, y = 0.8}),
        }
        storage.tasks.delayedTurnOffs[gate.id] = {tick = game.tick + 105, gate = gate}
    end
end

function activateGate(gate)
    if gate.dhd then
        gate.dhd.entity.minable_flag = false
        gate.dhd:SetButtonLight(true)
        gate.dhd:CloseGUIs()
        if storage.tasks.busyDhds and storage.tasks.busyDhds[gate.dhd.id] then
            storage.tasks.busyDhds[gate.dhd.id] = nil
        end
    end
    gate.active = true
    gate.childs.soundEnt = gate.entity.surface.create_entity{
        name = sgNames.sound,
        position = gate.entity.position,
    }
    gate.childs.soundEnt.destructible = false
    gate.entity.minable_flag = false
    gate.chevrons.animation_offset = 7

    storage.tasks.eventHorizons[gate.id] = {tick = game.tick + 1.5*60-5, gate = gate}

    util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_open")

    gate.entity.surface.create_entity {
        name = "kj_stargate_eventHorizon_woosh",
        position = util.vector2Add(gate.entity.position, {x = 0, y = 0.8}),
    }
    gate.entity.surface.create_entity {
        name = "kj_stargate_woosh",
        position = util.vector2Add(gate.entity.position, {x = 0, y = 0.8}),
    }
    gate.entity.surface.create_entity {
        name = "kj_stargate_woosh_glow",
        position = util.vector2Add(gate.entity.position, {x = 0, y = 0.55}),
    }

    --local effectPos1 = util.vector2Add(gate.entity.position, {x = 0, y = 2.5})
    --local effectPos2 = util.vector2Add(gate.entity.position, {x = 0, y = 5.5})
    --[[
    local radius = 2.5
    for x=-radius, radius, 1 do
        for y=-radius, radius, 1 do
            gate.entity.surface.create_entity {
                name = "land-mine",
                force = "player",
                position = util.vector2Add(effectPos1, {x = x, y = y}),
            }
            gate.entity.surface.create_entity {
                name = "land-mine",
                force = "player",
                position = util.vector2Add(effectPos2, {x = x, y = y}),
            }
        end
    end]]
end

function findRandomGateOnSurface(surface)
    local gates = {}
    for _, gate in pairs(storage.stargate[surface]) do
        if gate.active == false then
            table.insert(gates, gate)
        end
    end

    if #gates ~= 0 then
        return gates[math.random(#gates)]
    else
        return nil
    end
end

function addAddressToGlobal(surface, address)
    if surface.platform ~= nil then return end
    storage.addresses[surface.name] = storage.addresses[surface.name] or address
end

function generateAdress(surface)
    --setting up rng
    local mapSeed = surface.map_gen_settings.seed
    local hash = util.hash_fnv1a(mapSeed..surface.name)
    local generator = game.create_random_generator(hash)
    game.print(surface.name.. " - Game Seed: "..mapSeed.." - Custom Seed: "..hash)

    local result = {}
    local used = {}

    for i = 1, 6 do
        local char
        repeat
            local index = generator(1, #chevronChars)
            char = chevronChars[index]
        until not used[char]

        result[i] = char
        used[char] = true
    end
    local resultString = table.concat(result)

    game.print("Adress: "..resultString)
    return resultString
end

function GateTransit(gate, player, vehicle)
    local pos = util.vector2Add(gate.entity.position, sgOffset)
    util.playSoundOnSurface(player.surface, player.position, "kj_stargate_enter")
    player.teleport(
        pos,
        gate.entity.surface
    )
    if vehicle ~= nil then
        local speed = vehicle.speed
        local collBox = vehicle.prototype.collision_box
        local extraDistance = (math.abs(collBox.left_top.y) + math.abs(collBox.right_bottom.y)) / 2
        vehicle.teleport(
            util.vector2Add(pos, {x = 0, y = extraDistance + 0.25}),
            gate.entity.surface
        )
        --flip car in certain value ranges
        vehicle.orientation = (vehicle.orientation < 0.25 or vehicle.orientation > 0.75) and 0.5 or 0
        vehicle.speed = speed
        vehicle.set_driver(player)

        --local modus = (vehicle.orientation == 0) and defines.riding.acceleration.reversing or defines.riding.acceleration.accelerating
		player.riding_state = {acceleration = defines.riding.acceleration.nothing, direction = defines.riding.direction.straight}

        local duration = math.max(1, (1 / math.abs(speed)))
        table.insert(storage.tasks.vehicles, {tick = game.tick + duration, vehicle = vehicle})

        storage.ignoredVehicles[vehicle.unit_number] = game.tick + 10
    else
        local duration = math.max(5, (1 / player.character_running_speed) * 2.25)
        table.insert(storage.tasks.players, {tick = game.tick + duration, player = player})
    end

    local activeGate = storage.tasks.activeGates[gate.id]
    if activeGate then
        activeGate.tick = math.min(activeGate.tick + 3 * 60, activeGate.maxTick)
    end

    table.insert(storage.tasks.delayedSounds, {
        tick = game.tick + 5,
        surface = gate.entity.surface,
        position = gate.entity.position,
        sound = "kj_stargate_enter"
    })
    --util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_enter")
end

function AssembleLettersInDHDGUI(root, dhdSurface, dhd)
    dhd:OpenedGUI(root)
    glib.add(root, sg_guis.dhd_letter("poo_"..poo[dhdSurface], dhdSurface, dhd.id, dhd.addressLetters["poo_"..poo[dhdSurface]]))
    for _, char in ipairs(chevronChars) do
        glib.add(root, sg_guis.dhd_letter(char, dhdSurface, dhd.id, dhd.addressLetters[char]))
    end
    glib.add(root, sg_guis.dhd_letter("connect", dhdSurface, dhd.id, dhd.stargate.active))
end
