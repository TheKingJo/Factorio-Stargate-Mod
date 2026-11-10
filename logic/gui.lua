GUI = {}

function GUI.AddressBookTriggered(e, refresh)
    local player = game.players[e.player_index]
    local gates = storage.addressBook[player.force.name]
    local gui, refs = player.gui.screen.addBk, nil

    if not gui then
        gui, refs = glib.add(player.gui.screen, sg_guis.addBk_frame())
        gui.force_auto_center()
        gui.bring_to_front()
        player.opened = gui
        table.insert(storage.openGUIs.AddBk, gui)
    else
        gui.visible = true
        refs = {gates = gui.children[2].children[1].children[1].children[1].gates}
        if refresh and refresh == true then
            local surface = e.surface
            local ogIndex = refs.gates[surface].get_index_in_parent()

            refs.gates[surface].destroy()
            local newSurface = glib.add(refs.gates, sg_guis.addBk_address(surface, e.state))
            local current_index = newSurface.get_index_in_parent()

            while current_index > ogIndex do
                refs.gates.swap_children(current_index, current_index - 1)
                current_index = current_index - 1
            end
        else
            refs.gates.clear()
        end
    end

    if refs and refs.gates and not refresh then
        local count = 0
        for surface, state in pairs(gates) do
            if state > 0 then
                glib.add(refs.gates, sg_guis.addBk_address(surface, state))
                count = count + 1
            end
        end
        if count == 0 then
            glib.add(refs.gates, {
                args = {type = "frame", style = "bordered_frame"},
                style_mods = {horizontal_align = "left"},
                children = {{
                    args = {type = "flow", direction = "horizontal"},
                    style_mods = {horizontally_stretchable = true, horizontal_align = "center"},
                    children = {{
                        args = {type = "label", style = "frame_title", caption = {"addBk_empty"}},
                    }}
                }}
            })
        end
    end
end

function GUI.RefreshAllAddBks(force, surface, state)
    if #storage.openGUIs.AddBk == 0 then return end
    for i = #storage.openGUIs.AddBk, 1, -1 do
        local GUI = storage.openGUIs.AddBk[i]

        if not GUI then goto continue end
        if not GUI.valid then
            table.remove(storage.openGUIs.AddBk, i)
            goto continue
        end
        if not GUI.visible then
            goto continue
        end
        if force == game.players[GUI.player_index].force.name then
            GUI.AddressBookTriggered({
                prototype_name = "kj_stargate_addressBook",
                player_index = GUI.player_index,
                surface = surface,
                state = state,
            }, state ~= nil)
        end

        ::continue::
    end
end

function GUI.GDOTriggered(e, refresh)
    local player, gates = game.players[e.player_index], {}
    local entities = game.surfaces[player.surface_index].find_entities_filtered{
        position = player.position,
        radius = 10,
        name = {SGNAMES.entity, SGNAMES.entitySignaled}
    }

    for _, entity in pairs(entities) do
        local gate = storage["stargate"][entity.surface.name][entity.unit_number]

        if gate.active and gate.destination and gate.destination.manual == false then
            gates[gate.destination.childs.iris.unit_number] = gate.destination
        end
    end

    local gui, refs = player.gui.screen.gdo, nil
    if not gui then
        gui, refs = glib.add(player.gui.screen, sg_guis.gdo_frame())

        gui.force_auto_center()
        gui.bring_to_front()
        player.opened = gui
        table.insert(storage.openGUIs.GDO, gui)
    else
        gui.visible = true
        refs = {gates = gui.children[2].children[1].children[1].children[1].gates}
        if refresh and refresh == true then
            for _, child in pairs(refs.gates.children) do
                local irisID = child.tags.irisID

                if irisID then
                    local state, iris = "on", storage.irisedGates[tonumber(irisID)].childs.iris
                    if iris.power_switch_state == true then
                        state = "iris"
                    end
                    child.children[1].children[1].sprite = "kj_sg_gate_"..state
                end
            end
        else
            refs.gates.clear()
        end
    end

    if refs and refs.gates and not refresh then
        if not next(gates) then
            glib.add(refs.gates, {
                args = {type = "frame", style = "bordered_frame"},
                style_mods = {horizontal_align = "left"},
                children = {{
                    args = {type = "flow", direction = "horizontal"},
                    style_mods = {horizontally_stretchable = true, horizontal_align = "center"},
                    children = {{
                        args = {type = "label", style = "frame_title", caption = {"gdoGui3"}},
                    }}
                }}
            })
        else
            for id, gate in pairs(gates) do
                glib.add(refs.gates, sg_guis.gdo_gate(gate.entity.surface.name, id, gate.childs.iris))
            end
        end
    end
end

function GUI.RefreshAllGDOIris(mode)
    if #storage.openGUIs.GUI.GDOIris == 0 then return end

    for i = #storage.openGUIs.GUI.GDOIris, 1, -1 do
        local GUI = storage.openGUIs.GUI.GDOIris[i]

        if not GUI then goto continue end
        if not GUI.valid then
            table.remove(storage.openGUIs.GUI.GDOIris, i)
            goto continue
        end
        if not GUI.visible then goto continue end

        local gui = game.players[GUI.player_index].gui.relative.gdo_iris.children[2].children[1].children[1].gdos

        if mode.change then
            gui[mode.change[1]].name = mode.change[2]
            gui[mode.change[1]].text = mode.change[2]

        elseif mode.add then
            glib.add(gui, sg_guis.gdo_code(gui.tags.irisID, mode.add))

        elseif mode.delete then
            gui[mode.delete].destroy()
        end
        ::continue::
    end
end

function GUI.GDOIris(data)
    local player = game.players[data.player_index]
    local gui, refs = player.gui.relative.gdo_iris, nil

    if data.name == SGNAMES.iris then
        local irisID = data.unit_number or gui.tags.irisID
        local gate = storage.irisedGates[irisID]

        if not gui then
            gui, refs = glib.add(player.gui.relative, sg_guis.gdo_iris_frame(irisID))

            table.insert(storage.openGUIs.GUI.GDOIris, gui)
        else
            refs = {gdos = gui.children[2].children[1].children[1].gdos}
        end

        if refs and refs.gdos then
            refs.gdos.clear()
            for code, _ in pairs(gate.gdos) do
                glib.add(refs.gdos, sg_guis.gdo_code(irisID, code))
            end
        end
    else
        if gui then gui.destroy() end --no gdo gui in other power switches
    end
end
