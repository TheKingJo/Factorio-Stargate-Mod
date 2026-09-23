--forces teleported players to move down
--forces teleported vehicles to move down
--handles delayed (teleport) sounds
--handles delayed eventhorizon animations and woosh dmg areas
--handles delayed gate turnoffs
function OnTick(e)
    local players = storage.tasks.players
    local vehicles = storage.tasks.vehicles
    local sounds = storage.tasks.delayedSounds
    local eventHorizons = storage.tasks.eventHorizons
    local delayedTurnOffs = storage.tasks.delayedTurnOffs

    if players ~= nil then
        for i = #players, 1, -1 do
            local player = players[i]
            if game.tick < player.tick then
                player.player.walking_state = {
                    walking = true,
                    direction = 8
                }
            else
                table.remove(storage.tasks.players, i)
            end
        end
    end
    if vehicles ~= nil then
        for i = #vehicles, 1, -1 do
            local vehicle = vehicles[i]
            if vehicle.vehicle.valid then
                if game.tick > vehicle.tick then
                    local driver = vehicle.vehicle.get_driver()
                    if driver then
                        driver.riding_state = {acceleration = defines.riding.acceleration.nothing, direction = defines.riding.direction.straight}
                    end
                    table.remove(storage.tasks.vehicles, i)
                end
            else
                table.remove(storage.tasks.vehicles, i)
            end
        end
    end
    if sounds ~= nil then
        for i = #sounds, 1, -1 do
            local sound = sounds[i]
            if game.tick > sound.tick then
                util.playSoundOnSurface(sound.surface, sound.position, sound.sound)
                table.remove(storage.tasks.delayedSounds, i)
            end
        end
    end
    if eventHorizons ~= nil then
        for id, eH in pairs(eventHorizons) do
            if game.tick > eH.tick then
                local effectPos1 = util.vector2Add(eH.gate.pos, {x = 0, y = entOffY.eff1})
                local effectPos2 = util.vector2Add(eH.gate.pos, {x = 0, y = entOffY.eff2})

                eH.gate.animation = rendering.draw_animation{
                    animation = "kj_stargate_eventHorizon",
                    target = util.vector2Add(eH.gate.pos, {x = 0, y = (eH.gate.manual and -0.19 or -0.215)}),
                    surface = eH.gate.entity.surface,
                    render_layer = "object",
                }
                eH.gate.childs.dmg1 = eH.gate.entity.surface.create_entity {
                    name = "kj_stargate_woosh_dmg",
                    position = effectPos1,
                    force = "enemy",
                    target = effectPos1,
                    speed = 1,
                }
                eH.gate.childs.dmg2 = eH.gate.entity.surface.create_entity {
                    name = "kj_stargate_woosh_dmg",
                    position = effectPos2,
                    force = "enemy",
                    target = effectPos2,
                    speed = 1,
                }
                eH.gate.safeToTravel = true
                storage.tasks.eventHorizons[id] = nil
            end
        end
    end
    if delayedTurnOffs ~= nil then
        for id, dTO in pairs(delayedTurnOffs) do
            if game.tick > dTO.tick then
                dTO.gate.safeToTravel = false
                dTO.gate.destination = nil
                storage.tasks.delayedTurnOffs[id] = nil
            end
        end
    end
end

--2
--checks if players are in transfer areas
--first by distance, then by collision box overlap
function OnNthTickPlayer(e)
    if not storage.stargate then return end
    for _, player in pairs(game.players) do
        if not storage.stargate[player.surface.name] then return end

        for gID, gate in pairs(storage.stargate[player.surface.name]) do
            if gate.valid == true and gate.entity and gate.entity.valid then
                if gate.safeToTravel == true and gate.destination then
                    if not gate.childs.iris or (gate.childs.iris and gate.childs.iris.power_switch_state == false) then
                        local vehicle = player.physical_vehicle
                        if (vehicle and vehicle.prototype.type == "spider-vehicle") then return end
                        if util.getDistance(player.physical_position, gate.childs.tpArea.position) > 13 then return end

                        if vehicle == nil then --player not in vehicle
                            if player.character and util.boundingBoxesCollision(player.character.bounding_box, gate.childs.tpArea.bounding_box) then
                                --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                                GateTransit(gate.destination, player, vehicle)
                            end
                        else --player in vehicle
                            if storage.illegalCars[vehicle.name] then return end
                            local iV = storage.ignoredVehicles and storage.ignoredVehicles[vehicle.unit_number]
                            if not iV or (iV and iV < game.tick) then
                                if util.rotatedBoxInsideBoundingBox(vehicle.bounding_box, vehicle.orientation, gate.childs.tpArea.bounding_box) == true then
                                    --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                                    GateTransit(gate.destination, player, vehicle)
                                    iV = nil
                                end
                            end
                        end
                    end
                end
            else
                storage.stargate[player.surface.name][gID] = nil
            end
        end
    end
end

--4
--handles the s gate dialing jobs
  --first assigning each chevron, moving the rings
  --then making the call once its done
function OnNthTickSGateDialing(e)
    local signaledGates = storage.tasks.signaledGates
    if not signaledGates then return end

    --[[signaledGate = {
        gate = nil, --gate ref
        glyphs = {
            {letter = "a", tick = game.tick+60},
            {letter = "b", tick = game.tick+120},
        },
        pooID = "1"
    }]]
    for id, task in pairs(signaledGates) do
        if not task.gate.entity.valid then
            signaledGates[id] = nil
            goto continue
        end

        local childs = task.gate.childs
        if #task.glyphs > 0 then
            --local drain = task.gate.entity.electric_drain * 60 --in W aka 10 MW max
            --local limit = task.gate.entity.power_usage * 60 --in W aka 100 MW
            --if drain < limit * 0.5 then return end --atm a bit useless to check since its draining its own capacitor so will likely be always true

            local glyph = task.glyphs[1]
            if game.tick >= glyph.tick then
                --game.print("tick: "..math.floor(game.tick))
                if glyph.letter then
                    --game.print("Locked Chevron "..glyph.letter)
                    local temp = "2"
                    table.insert(task.gate.destAddress, glyph.letter)
                    task.gate:SetRotationFromGlyph(glyph.letter)
                    task.gate.lastGlyph = glyph.letter
                    if #task.glyphs > 1 then
                        task.gate.chevrons.animation_offset = task.gate.chevrons.animation_offset + 1
                        temp = ""
                    end

                    task.gate.sAnim1 = task.gate.entity.surface.create_entity {
                        name = "kj_stargate_chevron_s_anim"..temp,
                        position = util.vector2Add(task.gate.pos, {x = 0, y = 1.5}),
                    }
                    task.gate.sAnim2 = task.gate.entity.surface.create_entity {
                        name = "kj_stargate_chevron_s_anim_sound2",
                        position = util.vector2Add(task.gate.pos, {x = 0, y = 1.5}),
                    }
                end
                childs.ringSound.power_switch_state = not childs.ringSound.power_switch_state

                childs.rings.riding_state = {
                    acceleration = defines.riding.acceleration.nothing,
                    direction = glyph.direction or 1,
                }

                table.remove(task.glyphs, 1)
            end
        else
            if game.tick < task.lastChevronTick then goto continue end
            task.gate.chevrons.animation_offset = task.gate.chevrons.animation_offset + 1
            childs.rings.riding_state = {
                acceleration = defines.riding.acceleration.nothing,
                direction = defines.riding.direction.straight,
            }
            local success = false
            if task.gate.entity.energy == 10^9 then
                game.print("Address dialing: "..task.gate:GetDestAddress().." "..util.getSignalFromChar(task.gate:GetDestAddress().."_"..poo[task.gate.entity.surface.name], true))

                if task.pooID == poo[task.gate.entity.surface.name] then --is poo glyph correct one (momentarily obsolete though)
                    for surf, address in pairs(storage.addresses) do
                        if surf ~= task.gate.entity.surface.name then --not on same surface
                            if address.."poo" == task.gate:GetDestAddress() then
                                game.print("Address found: "..surf)
                                if task.gate:Connect(findRandomGateOnSurface(surf)) then
                                    success = true
                                end
                            end
                        end
                    end
                end

                task.gate.entity.energy = 0
                task.gate:SetEnergyStatus()
            else
                game.print("Not enough electricity")
                task.gate.entity.surface.create_entity {
                    name = "kj_stargate_electricFailure",
                    position = util.vector2Add(task.gate.pos, {x = 0, y = entOffY.eF}),
                }
            end

            if success == true then
                task.gate:SetSenderStatus(true)
                task.gate.entity.electric_buffer_size = 10^7
            else
                task.gate:SetSenderStatus(false)
                task.gate.entity.minable_flag = true
                task.gate.chevrons.animation_offset = 0
                util.playSoundOnSurface(task.gate.entity.surface, task.gate.pos, "kj_stargate_fail")
            end
            task.gate:RefreshRecentAddressesInSender()
            task.gate:Reset()
            signaledGates[id] = nil
            task.gate.senderLastTick = game.tick
        end
        ::continue::
    end
end

--10
--checks all s gates if they got signal input
  --creating dial job
  --canceling dial jobs
  --checking if dial signal is still there during dialing
  --TODO: checking if electricity is on during dialing
function OnNthTickSGates(e)
    if not storage.stargate then return end

    for _, surface in pairs(storage.stargate) do
        for _, gate in pairs(surface) do
            if gate.manual == true then goto continue end
            --if not gate.childs.signalReceiver then surface[id] = nil return end
            gate:SetEnergyStatus()
            local receiver = gate.childs.signalReceiver
            local signals = receiver.get_signals(1)

            if gate.active == false and storage.tasks.signaledGates[gate.id] == nil then --gate is inactive and also not dialing
                if gate.safeToTravel == false and signals ~= nil and game.tick > (gate.senderLastTick or 0) then
                    --if gate.entity and gate.entity.energy ~= 10^9 then return end
                    local address = ""
                    local addressLetters = {}
                    local letterIndex = 1
                    local successful = false
                    local disConnect = 0
                    local pooGlyphID = ""
                    local surfaceName = gate.entity.surface.name

                    table.sort(signals, function(a, b) --sort ascending
                        return a.count < b.count
                    end)

                    for _, signal in ipairs(signals) do
                        local glyph = signal.signal.name:match("^kj_sg_glyph_(.+)$")

                        if charLookup[glyph] ~= nil then --signal is a glyph
                            if letterIndex == signal.count then --glyph has correct count
                                if glyph ~= "poo_"..poo[surfaceName] then --glyph is a letter, gets concat to address
                                    table.insert(addressLetters, glyph)
                                    address = address..glyph
                                else
                                    if letterIndex == 7 and tonumber(glyph:match("_(%d+)$")) == poo[surfaceName] then --is poo glyph same as surface
                                        pooGlyphID = poo[surfaceName]
                                        table.insert(addressLetters, "poo")
                                        successful = true
                                    end
                                end

                                letterIndex = letterIndex + 1
                            else
                                break --letter sequence broken, abort
                            end
                        else
                            if glyph == "connect" then --signal is connection command
                                if signal.count == 1 then
                                    disConnect = 1
                                else
                                    disConnect = -1
                                    break
                                end
                            end
                        end
                    end

                    if successful == true and disConnect == 1 then
                        local task = {gate = gate, glyphs = {}, pooID = pooGlyphID, lastChevronTick = game.tick}
                        local prevLetter = gate.lastGlyph or "poo"
                        local offset = 0

                        --table.insert(task.glyphs, {tick = 0})
                        game.print("Tick: "..game.tick)
                        for i, letter in ipairs(addressLetters) do
                            table.insert(task.glyphs, {tick = game.tick + offset})

                            local distance, dir = util.getRingGlyphDistance(prevLetter, letter)
                            localOffset = math.floor(3*60*(distance / 19)) --3s per half cycle
                            offset = offset + localOffset

                            game.print("Distance: "..prevLetter.." -> "..letter.." - "..distance.." around "..direction[dir+1].." with offset "..localOffset)
                            table.insert(task.glyphs, {letter = letter, tick = game.tick + offset})

                            task.glyphs[#task.glyphs - 1].direction = dir
                            prevLetter = letter
                            gate.destAddressLetters[letter] = i

                            offset = offset + 120 --offset for the stop sound and animation
                        end
                        task.lastChevronTick = offset + game.tick

                        gate.entity.minable_flag = false
                        storage.tasks.signaledGates[gate.id] = task
                        gate:ResetSenderStatus()
                    end
                    game.print("Address entered: "..address.." "..util.getSignalFromChar(address, true))
                end
            else --gate is connected or dialing
                local success = true

                if gate.active == false then --gate is dialing
                    if storage.tasks.signaledGates[gate.id] ~= nil then
                        local pooLookup = {[7] = "_"..storage.tasks.signaledGates[gate.id].pooID}
                        for letter, index in pairs(gate.destAddressLetters) do
                            if receiver.get_signal({type = "virtual", name = "kj_sg_glyph_"..letter..(pooLookup[index] or "")}, 1) ~= index then
                                success = false
                                break
                            end
                        end
                    end
                    --abort while dialing
                    if receiver.get_signal({type = "virtual", name = "kj_sg_glyph_connect"}, 1) == -1 then
                        success = false
                    end
                end

                --signal changed while dialing
                if success == false then
                    if gate.sAnim1 then gate.sAnim1.destroy() end
                    if gate.sAnim2 then gate.sAnim2.destroy() end
                    util.playSoundOnSurface(gate.entity.surface, gate.pos, "kj_stargate_s_fail")
                end
                --either address is false or abort signal was there
                if success == false or receiver.get_signal({type = "virtual", name = "kj_sg_glyph_connect"}, 1) == -1 then
                    gate.childs.ringSound.power_switch_state = false
                    gate.entity.minable_flag = true

                    gate:Disconnect()
                    gate:Reset()
                    storage.tasks.signaledGates[gate.id] = nil
                end
            end
            ::continue::
        end
    end
end

--60
--tracks:
---gate connection timeouts
---open dhd interfaces afk timeouts
function OnNthTickTasks(e)
    local gates = storage.tasks.activeGates
    local dhds = storage.tasks.busyDhds

    if not storage.infCon then
        if gates ~= nil then
            for id, gate in pairs(gates) do
                if game.tick > gate.tick then
                    gate.stargate:Disconnect()
                    storage.tasks.activeGates[id] = nil
                end
            end
        end
    end

    if dhds ~= nil then
        for id, dhd in pairs(dhds) do
            if game.tick > dhd.tick then
                dhd.dhd:Connect("deineMom")
                storage.tasks.busyDhds[id] = nil
            end
        end
    end
end
