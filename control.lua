if script.active_mods["gvv"] then require("__gvv__.gvv")() end
util = require("utils")
sg_guis = require("logic.gui")
mod_gui = require("mod-gui")
glib = require("__glib__/glib")

local sgNames = {
    placement = "kj_stargate_placement",
    base = "kj_stargate_base",
    sound = "kj_stargate_ambientSound",
    tpArea = "kj_stargate_transferArea",
    colliderV = "kj_stargate_colliderVert",
    colliderH1 = "kj_stargate_colliderHori1",
    colliderH2 = "kj_stargate_colliderHori2",
    colliderD = "kj_stargate_colliderDiag",
}
local dhdName = "kj_dhd"
local sgOffset = {x = 0, y = 1.3}
local poo = {
    nauvis = 1,
    gleba = 5,
    aquilo = 2,
    vulcanus = 4,
    fulgora = 3,
}

local chevronChars = {}
for i = string.byte("A"), string.byte("S") do
    table.insert(chevronChars, string.char(i))
end
for i = string.byte("a"), string.byte("s") do
    table.insert(chevronChars, string.char(i))
end

local poos = 5
charLookup = {}
for i, char in ipairs(chevronChars) do
    charLookup[char] = i
end
for i = 1, poos, 1 do
    charLookup["poo_"..i] = 1
end

--at start check for existing char tables
--regen when not existing
--otherwise generate on surface generation


stargate = {
	Connect = function(thisGate, otherGate)
        if otherGate.destination ~= nil then --other gate has connection
            thisGate.dhd:ResetGlyphs()
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

            storage.activeGates = storage.activeGates or {}
            storage.activeGates[thisGate.id] = {tick = game.tick + 20*60, stargate = thisGate}

            game.print("Gates connected: "..thisGate.id.."|"..otherGate.id)
        end
	end,

    Disconnect = function(self)
        local dest = self.destination
        if dest then
            deactivateGate(self)
            deactivateGate(dest)

            storage.activeGates[self.id] = nil
            game.print("Gates disconnected: "..self.id.."|"..dest.id)
        end
    end,
}

dhd = {
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
        self.address = util.lettersFromAddress(storage.addresses[otherGate.entity.surface.name], "poo_"..poo[otherGate.entity.surface.name])
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
            if selfAddress == address.."poo_"..poo[dhdSurface] then
                surface = s
                result = true
            end
        end

        if storage.stargate[surface] == nil then result = false end

        if result == true then
            game.print("omg we found a connection!")
            self.stargate:Connect(findRandomGateOnSurface(surface))
        else
            util.playSoundOnSurface(self.stargate.entity.surface, self.stargate.entity.position, "kj_stargate_fail")
            game.print("no gate with that address. emptying ram")
            self:ResetGlyphs()
            self.stargate.chevrons.animation_offset = 0
            self.address = {}
            self.addressLetters = {}
        end
	end,

    Disconnect = function(self)
        self.stargate:Disconnect()
    end,

    TrackIdling = function(self)
        storage.unidledDhds = storage.unidledDhds or {}
        storage.unidledDhds[self.id] = {tick = game.tick + 20*60, dhd = self}
    end,
}

function deactivateGate(gate)
    if gate.dhd then
        gate.dhd.entity.minable = true
        gate.dhd:SetButtonLight(false)
        if gate.dhd.address then
            gate.dhd:ResetGlyphs()
            gate.dhd.address = {}
            gate.dhd.addressLetters = {}
        end
    end
    gate.childs.soundEnt.destroy()
    gate.entity.minable = true
    gate.active = false
    gate.chevrons.animation_offset = 0
    gate.animation.destroy()
    gate.destination = nil
    util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_close")
end

function activateGate(gate)
    if gate.dhd then
        gate.dhd.entity.minable = false
        gate.dhd:SetButtonLight(true)
    end
    gate.active = true
    --[[gate.animation = rendering.draw_animation{
        animation = "kj_stargate_eventHorizon",
        target = util.vector2Add(gate.entity.position, {x = 0, y = -10.2}),--gate.childs.baseEnt,
        surface = gate.entity.surface,
        render_layer = "object",
        y_scale = 5,
    }]]
    gate.childs.soundEnt = gate.entity.surface.create_entity{
        name = sgNames.sound,
        position = gate.entity.position,
    }
    gate.chevrons.animation_offset = 7
    gate.animation = gate.entity.surface.create_entity{
        name = "kj_stargate_eventHorizon_ent",
        position = util.vector2Add(gate.entity.position, {x = 0, y = -0.19}),
    }
    gate.animation.destructible = false
    gate.entity.minable = false
    util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_open")

    local effectPos = util.vector2Add(gate.entity.position, {x = 0, y = 2.5})
    gate.entity.surface.create_entity {
        name = "kj_stargate_woosh",
        position = effectPos,
        force = "enemy",
        target = effectPos,
        speed = 1,
    }
end

function findRandomGateOnSurface(surface)
    local gates = {}
    for _, gate in pairs(storage.stargate[surface]) do
        table.insert(gates, gate)
    end
    local numb = math.random(#gates)
    return gates[numb]
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
    for _, surface in pairs(game.surfaces) do
        addAddressToGlobal(surface, generateAdress(surface))
        Chunk({
            position = {x = 0, y = 0},
            surface = surface
        })
    end
end

function addAddressToGlobal(surface, address)
    if surface.platform ~= nil then return end
    storage.addresses = storage.addresses or {}
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
        vehicle.teleport(
            pos,
            gate.entity.surface
        )
        --flip car in certain value ranges
        vehicle.orientation = (vehicle.orientation < 0.25 or vehicle.orientation > 0.75) and 0.5 or 0
        vehicle.speed = speed
        vehicle.set_driver(player)

        local modus = (vehicle.orientation == 0) and defines.riding.acceleration.reversing or defines.riding.acceleration.accelerating
		player.riding_state = {acceleration = modus, direction = defines.riding.direction.straight}

        storage.vehicles = storage.vehicles or {}
        table.insert(storage.vehicles, {tick = game.tick + 5, vehicle = vehicle})

        storage.ignoredVehicles = storage.ignoredVehicles or {}
        storage.ignoredVehicles[vehicle.unit_number] = game.tick + 10
    else
        storage.players = storage.players or {}
        table.insert(storage.players, {tick = game.tick + 15, player = player})
    end
    util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_enter")
end

function OnBuilt(e)
	local ent = e.entity
    if not ent.valid then return end
    --game.print("Placed "..ent.name)

	if ent.name == sgNames.placement then --stargate placed
        local pos = ent.position
        local surface = ent.surface
        local tpArea = surface.create_entity{
            name = sgNames.tpArea,
            position = util.vector2Add(pos, {x = 0, y = -1.8}),
        }
        local chevrons = rendering.draw_animation{
            animation = "kj_stargate_chevrons",
            target = util.vector2Add(pos, {x = 0, y = -2}),
            surface = surface,
            render_layer = "object",
            animation_speed = 0,
        }
        local childs = {
            baseEnt = surface.create_entity{
                name = sgNames.base,
                position = util.vector2Add(pos, {x = 0, y = -2}),
            },
            colliderV1 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = -3.5, y = -1}),
            },
            colliderV2 = surface.create_entity{
                name = sgNames.colliderV,
                position = util.vector2Add(pos, {x = 3.5, y = -1}),
            },
            colliderH11 = surface.create_entity{
                name = sgNames.colliderH1,
                position = util.vector2Add(pos, {x = 0, y = -2.275}),
            },
            colliderH21 = surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(pos, {x = -2.5, y = -0.5}),
            },
            colliderH22 = surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(pos, {x = 2.5, y = -0.5}),
            },
            colliderH31 = surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(pos, {x = -2.25, y = -1.6}),
            },
            colliderH32 = surface.create_entity{
                name = sgNames.colliderH2,
                position = util.vector2Add(pos, {x = 2.25, y = -1.6}),
            },
            colliderD1 = surface.create_entity{
                name = sgNames.colliderD,
                position = util.vector2Add(pos, {x = -2.366, y = 0.225}),
                direction = defines.direction.southeast,
            },
            colliderD2 = surface.create_entity{
                name = sgNames.colliderD,
                position = util.vector2Add(pos, {x = 2.366, y = 0.225}),
                direction = defines.direction.southwest,
            },
        }

        for _, child in pairs(childs) do
            child.destructible = false
        end

        local posis = {x = {-0.5, -1.5}, y = {0, 1, 2}}
        local calcPosis = {}
        for i = 1, -1, -2 do
            for _, x in pairs(posis.x) do
                for _, y in pairs(posis.y) do
                    table.insert(calcPosis, {position = util.vector2Add(pos, {x*i,y}), name = "kj_stargate_slowDownTile"})
                end
            end
        end
        table.insert(calcPosis, {position = util.vector2Add(pos, {-2.5, 2}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, { 2.5, 2}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, {-2.5, 1}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, { 2.5, 1}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, {-3.5, 2}), name = "kj_stargate_slowDownTile"})
        table.insert(calcPosis, {position = util.vector2Add(pos, { 3.5, 2}), name = "kj_stargate_slowDownTile"})

        local oldTiles = {}
        for _, tile in pairs(calcPosis) do
            tile = surface.get_tile(tile.position.x, tile.position.y)
            table.insert(oldTiles, {name = tile.name, position = tile.position})
        end

        surface.set_tiles(calcPosis)

        local content = {
            valid = true,
            active = false,
            childs = childs,
            oldTiles = oldTiles,
            destination = nil,
            chevrons = chevrons,
        }
        util.addToGlobal("stargate", tpArea, content)

        ent.destroy()
    elseif ent.name == dhdName then --dhd placed
        ent.destructible = false
        ent.rotatable = false

        local glyphAnimation = {}
        for i = 1, 7, 1 do
            table.insert(glyphAnimation, rendering.draw_animation{
                animation = "kj_stargate_dhd_"..ent.direction,
                animation_speed = 0,
                target = ent.position,
                surface = ent.surface,
                render_layer = "object",
            })
        end

        local content = {
            address = {},
            addressLetters = {},
            glyphs = glyphAnimation
        }
        local dhd = util.addToGlobal("dhd", ent, content)
        if dhd.stargate and dhd.stargate.destination and dhd.stargate.active then
            dhd:SetButtonLight(true)
            dhd:FetchAddress(dhd.stargate.destination)
            dhd:SetGlyphs()
        end
    end
end

function OnRemoved(e)
	local ent = e.entity
    if not ent.valid then return end

	if ent.name == sgNames.tpArea then
        local sg = util.findInGlobal("stargate", ent)
        if sg.oldTiles then
            ent.surface.set_tiles(sg.oldTiles)
        end

        util.removeFromGlobal("stargate", ent)

    elseif ent.name == dhdName then
        local stargate = util.removeFromGlobal("dhd", ent)

        if stargate ~= nil and stargate.active == true then --cutting connection ?
            --stargate.active = false
            --stargate.destination = nil
            --util.playSoundOnSurface(ent.surface, stargate.entity.position, "kj_stargate_close")
            --if stargate.animation then stargate.animation.destroy() end
        end
    end
end

function OnTick(e)
    local players = storage.players
    local vehicles = storage.vehicles

    if players ~= nil then
        for i = #players, 1, -1 do
            local player = players[i]
            if game.tick < player.tick then
                player.player.walking_state = {
                    walking = true,
                    direction = 8
                }
            else
                table.remove(storage.players, i)
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
                    table.remove(storage.vehicles, i)
                end
            else
                table.remove(storage.vehicles, i)
            end
        end
    end
end

function OnNthTickPlayer(e)
    if not storage.stargate then return end
    local deleteGate = {}
    for sgSurface, gates in pairs(storage.stargate) do
        for gID, gate in pairs(gates) do
            if gate.valid == true and gate.entity and gate.entity.valid then
                if gate.active == true and gate.destination then
                    for _, player in pairs(game.players) do
                        local vehicle = player.physical_vehicle
                        if player.surface.name == sgSurface and not (vehicle and vehicle.prototype.type == "spider-vehicle") then
                            if vehicle == nil then --player not in vehicle
                                if util.positionInBoundingBox(player.physical_position, gate.entity.bounding_box) == true then
                                    --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                                    GateTransit(gate.destination, player, vehicle)
                                end
                            else --player in vehicle
                                local iV = storage.ignoredVehicles and storage.ignoredVehicles[vehicle.unit_number]
                                if not iV or (iV and iV < game.tick) then
                                    if util.rotatedBoxInsideBoundingBox(vehicle.bounding_box, vehicle.orientation, gate.entity.bounding_box) == true then
                                        --game.print(e.tick.." - Player "..player.name.." entered gate on "..player.surface.name)

                                        GateTransit(gate.destination, player, vehicle)
                                        iV = nil
                                    end
                                end
                            end
                        end
                    end
                end
            else
                deleteGate.sgSurface = gID
            end
        end
    end

    for v, k in ipairs(deleteGate) do
        storage.stargate[v][k] = nil
    end
end

function OnNthTickGates(e)
    local gates = storage.activeGates
    local dhds = storage.unidledDhds
    local deleteGate = {}
    local deleteDhd = {}

    if gates ~= nil then
        for id, gate in pairs(gates) do
            if game.tick > gate.tick then
                gate.stargate:Disconnect()
                table.insert(deleteGate, id)
            end
        end
    end
    for _, k in ipairs(deleteGate) do
        storage.activeGates[k] = nil
    end

    if dhds ~= nil then
        for id, dhd in pairs(dhds) do
            if game.tick > dhd.tick then
                dhd.dhd:Connect(dhd.dhd.entity.surface.name)
                table.insert(deleteDhd, id)
            end
        end
    end
    for _, k in ipairs(deleteDhd) do
        storage.unidledDhds[k] = nil
    end
end

function GuiOpened(e)
    local player = game.players[e.player_index]

    if e.entity and e.entity.name == "kj_dhd" then
        local dhd, dhdID = util.findInGlobal("dhd", e.entity)
        if dhd == nil or dhd.stargate == nil then
            player.opened = nil
            return
        end

        gui = player.gui.screen.dhd
        local refs
        if not gui then
            gui, refs = glib.add(player.gui.screen, sg_guis.dhd_frame_new("dhd", {"dhd"}))
        else
            gui.visible = true
        end

        if refs.stargates then
            AssembleLettersInDHDGUI(refs.stargates, e.entity.surface.name, dhd)
        end

        gui.force_auto_center()
        gui.bring_to_front()
        player.opened = gui
    end
end

function AssembleLettersInDHDGUI(root, dhdSurface, dhd)
    glib.add(root, sg_guis.dhd_letter("poo_"..poo[dhdSurface], dhdSurface, dhd.id, dhd.addressLetters["poo_"..poo[dhdSurface]]))
    for _, char in ipairs(chevronChars) do
        glib.add(root, sg_guis.dhd_letter(char, dhdSurface, dhd.id, dhd.addressLetters[char]))
    end
    glib.add(root, sg_guis.dhd_letter("connect", dhdSurface, dhd.id, dhd.stargate.active))
end

function Chunk(e)
    local position = e.position
    local surface = e.surface
    if surface.platform ~= nil then return end

    if position.x == 0 and position.y == 0 then
        local pos
        local i = 0
        repeat
            i = i + 1
            pos = {math.random(-100,100), math.random(-100,100)}
            pos = surface.find_non_colliding_position("kj_stargate_auto_gen", pos, 5, 1, false)
        until pos ~= nil or i == 20

        if pos == nil then
            pos = surface.find_non_colliding_position("kj_stargate_auto_gen", {0,0}, 1000, 1, false)
        end

        if pos ~= nil then
            local ent = surface.create_entity{
                name = "kj_stargate_auto_gen",
                position = pos,
                force = "neutral",
                direction = math.random(0,3)*4
            }
            ent.graphics_variation = math.random(1,4)
            game.print("Placed stargate at [gps="..pos.x..","..pos.y..","..surface.name.."]. Needed "..i.." attempts.")
        else
            game.print("Couldn't place stargate on "..surface.name.."! Starting area too crowded.")
        end
    end
end

script.on_event(defines.events.on_built_entity, OnBuilt)
script.on_event(defines.events.on_robot_built_entity, OnBuilt)

script.on_load(OnLoad)
--script.on_configuration_changed(OnConfigChanged)

script.on_event(defines.events.on_player_mined_entity, OnRemoved)
script.on_event(defines.events.on_robot_mined_entity, OnRemoved)
script.on_event(defines.events.on_entity_died, OnRemoved)

script.on_event(defines.events.on_tick, OnTick)
script.on_nth_tick(60, OnNthTickGates)
script.on_nth_tick(2, OnNthTickPlayer)

script.on_event(defines.events.on_surface_created,
    function(event)
        local surface = game.surfaces[event.surface_index]
        addAddressToGlobal(surface, generateAdress(surface))
    end
)

script.on_event(defines.events.on_gui_opened, GuiOpened)
script.on_event(defines.events.on_chunk_generated, Chunk)

script.on_init(OnInit)

--turn surface name into number and combine with map seed

--[[
    surface name + game seed -> seed
    ->generate adress
]]