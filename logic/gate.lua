stargate = {
    Initialize = function(self)
    end,

	Connect = function(thisGate, otherGate)
        if otherGate == nil then return nil end
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

        return true
	end,

    Disconnect = function(self, override)
        local dest = self.destination
        if dest then
            if not self.manual then
                self.entity.electric_buffer_size = 10^9
            end
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
        self:ResetAddress()

        if self.childs.rings then
            self.childs.rings.riding_state = {
                acceleration = defines.riding.acceleration.nothing,
                direction = 1,
            }
        end
    end,

    GetDestAddress = function(self)
        if self.destAddress then
            return table.concat(self.destAddress)
        else
            return nil
        end
    end,

    ResetAddress = function(self)
        table.insert(self.recentAddresses, 1, self.destAddress)
        if #self.recentAddresses > 5 then
            for i = 6, #self.recentAddresses, 1 do
                table.remove(self.recentAddresses, i)
            end
        end
        --TODO implement cc section establishing and shifting by quality and index yada yada
        if self.destAddress then
            self.destAddress = {}
            self.destAddressLetters = {}
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
        gate.childs.eHShort = gate.entity.surface.create_entity {
            name = "kj_stargate_eventHorizon_short",
            position = util.vector2Add(gate.entity.position, {x = 0, y = (gate.manual and 0.5 or 0.45)}),
        }
        gate.childs.wooshBckw = gate.entity.surface.create_entity {
            name = "kj_stargate_eventHorizon_woosh_backward",
            position = util.vector2Add(gate.entity.position, {x = 0, y = (gate.manual and 0.5 or 0.45)}),
        }

        --check for already existing turnoffs, so it doesn't get edged to eternity in case of an error
        local tick = game.tick
        if storage.tasks.delayedTurnOffs[gate.id] == nil then
            tick = tick + 105
        else
            tick = math.min(tick + 105, storage.tasks.delayedTurnOffs[gate.id].tick)
        end
        storage.tasks.delayedTurnOffs[gate.id] = {tick = tick, gate = gate}
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

    gate.childs.eHwoosh = gate.entity.surface.create_entity {
        name = "kj_stargate_eventHorizon_woosh",
        position = util.vector2Add(gate.entity.position, {x = 0, y = (gate.manual and 0.5 or 0.45)}),
    }
    gate.childs.woosh = gate.entity.surface.create_entity {
        name = "kj_stargate_woosh",
        position = util.vector2Add(gate.entity.position, {x = 0, y = 0.8}),
    }
    gate.childs.wooshGlow = gate.entity.surface.create_entity {
        name = "kj_stargate_woosh_glow"..(gate.manual and "" or "_s"),
        position = util.vector2Add(gate.entity.position, {x = 0, y = 0.55}),
    }
end

function findRandomGateOnSurface(surface)
    local gates = {}
    if not storage.stargate[surface] then return nil end
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

    game.print("Address: "..resultString..util.getSignalFromChar(resultString, true))
    return resultString
end

function FindFreeTeleportArea(gate, name, pos)
    local teleportSpaces = {
        {
            {{0, 0}, {0, 0}},
            {{-2, -0.5}, {2, 1}},
            {{-1, 1}, {1, 3}},
            {{-4, 1}, {4, 3}},
            3
        },
        {
            {{0, 0}, {0, 0}},
            {{-1, -0.5}, {1, 1}},
            {{-1, 1}, {1, 5}},
            {{-5, 0}, {5, 6}},
            4
        },
    }
    local type = 1
    local surface = gate.entity.surface
    if not gate.manual then
        type = 2
    end
    local teleportPosition
    local i = 0

    repeat
        i = i + 1
        teleportPosition = surface.find_non_colliding_position_in_box(name,
            {util.vector2Add(pos, teleportSpaces[type][i][1]), util.vector2Add(pos, teleportSpaces[type][i][2])}, 0.01)
    until teleportPosition ~= nil or i == 4

    if teleportPosition == nil then
        teleportPosition = surface.find_non_colliding_position(name, util.vector2Add(pos, {0, teleportSpaces[type][5]}), teleportSpaces[type][5] + 0.5, 0.01)
    end
    if teleportPosition == nil then
        teleportPosition = pos
    end

    return teleportPosition
end

function GateTransit(gate, player, vehicle)
    local pos = util.vector2Add(gate.entity.position, sgOffset)
    local surface = gate.entity.surface
    util.playSoundOnSurface(player.surface, player.position, "kj_stargate_enter")

    player.teleport(
        FindFreeTeleportArea(gate, player.character.name, pos),
        surface
    )
    if vehicle ~= nil and vehicle.name ~= "kj_stargate_ring" then
        local speed = vehicle.speed
        local collBox = vehicle.prototype.collision_box
        local extraDistance = (math.abs(collBox.left_top.y) + math.abs(collBox.right_bottom.y)) / 2
        vehicle.teleport(
            FindFreeTeleportArea(gate, vehicle.name, util.vector2Add(pos, {x = 0, y = extraDistance + 0.25})),
            surface
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
        surface = surface,
        position = gate.entity.position,
        sound = "kj_stargate_enter"
    })
    --util.playSoundOnSurface(surface, gate.entity.position, "kj_stargate_enter")
end

function AssembleLettersInDHDGUI(root, dhdSurface, dhd)
    dhd:OpenedGUI(root)
    glib.add(root, sg_guis.dhd_letter("poo_"..poo[dhdSurface], dhdSurface, dhd.id, dhd.addressLetters["poo_"..poo[dhdSurface]]))
    for _, char in ipairs(chevronChars) do
        glib.add(root, sg_guis.dhd_letter(char, dhdSurface, dhd.id, dhd.addressLetters[char]))
    end
    glib.add(root, sg_guis.dhd_letter("connect", dhdSurface, dhd.id, dhd.stargate.active))
end
