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
        local root = storage.openGUIs.AddBk[i]

        if not root then goto continue end
        if not root.valid then
            table.remove(storage.openGUIs.AddBk, i)
            goto continue
        end
        if not root.visible then
            goto continue
        end
        if force == game.players[root.player_index].force.name then
            GUI.AddressBookTriggered({
                prototype_name = "kj_stargate_addressBook",
                player_index = root.player_index,
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

        if gate.active and gate.destination and not gate.destination.manual then
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
    if #storage.openGUIs.GDOIris == 0 then return end

    for i = #storage.openGUIs.GDOIris, 1, -1 do
        local root = storage.openGUIs.GDOIris[i]

        if not root then goto continue end
        if not root.valid then
            table.remove(storage.openGUIs.GDOIris, i)
            goto continue
        end
        if not root.visible then goto continue end

        root = game.players[root.player_index].gui.relative.gdo_iris.children[2].children[1].children[1].gdos

        if mode.change then
            root[mode.change[1]].textField.text = mode.change[2]
            root[mode.change[1]].name = mode.change[2]

        elseif mode.add then
            glib.add(root, sg_guis.gdo_code(root.tags.irisID, mode.add))

        elseif mode.delete then
            root[mode.delete].destroy()
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

            table.insert(storage.openGUIs.GDOIris, gui)
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

function GUI.RefreshDHDs(player_index, dhd, status)
    if #storage.openGUIs.DHD == 0 then return end
    for i = #storage.openGUIs.DHD, 1, -1 do
        local root = storage.openGUIs.DHD[i]

        if not root then goto continue end
        if not root.valid then
            table.remove(storage.openGUIs.DHD, i)
            goto continue
        end
        if not root.visible then goto continue end

        if root.player_index ~= player_index then
            GUI.DHD({
                entity = dhd.entity,
                player_index = root.player_index,
                status = status,
            }, true)
        end

        ::continue::
    end
end

function GUI.DHD(e, refresh)
    local player = game.players[e.player_index]
    local dhd, _ = e.dhd or util.findInGlobal("dhd", e.entity), nil
    if dhd == nil or dhd.stargate == nil then
        player.opened = nil
        return
    end

    local gui, refs = player.gui.screen.dhd, nil

    if not refresh then
        if gui then gui.destroy() end --always rebuild, old buttons may carry tags of another dhd
        gui, refs = glib.add(player.gui.screen, sg_guis.dhd_frame_new())
        table.insert(storage.openGUIs.DHD, gui)
        gui.force_auto_center()
    else
        gui.children[2].children[1].children[1].children[1].destroy() --destroy glyph button collection
        _, refs = glib.add(gui.children[2].children[1].children[1], sg_guis.dhd_grid_def)
    end

    if refs.glyphs then
        local surface, state, connectCell, keys = e.entity.surface.name, false, sg_guis.dhd_grid_info.at[3][3], {}
        dhd:OpenGUI(gui)

        if dhd.stargate.travelDirection == "sender" and dhd.stargate.active == true then
            state = true
        end
        glib.add(refs["cell_"..connectCell], sg_guis.dhd_letter({"connect", surface, dhd.id, e.status or state, true}))

        for _, char in ipairs(chevronChars) do
            table.insert(keys, char)
        end
        table.insert(keys, 11, "poo_"..POO[surface])

        --cells that stay empty
        local cell = 0
        for _, char in ipairs(keys) do
            cell = cell + 1
            while skipCells[cell] do --fill placeholders until the next char cell
                if cell ~= connectCell then
                    glib.add(refs["cell_"..cell], sg_guis.dhd_letter({}, true))
                end
                cell = cell + 1
            end
            glib.add(refs["cell_"..cell], sg_guis.dhd_letter({char, surface, dhd.id, dhd.addressLetters[char], dhdGridSizes[cell]}))
        end
    end

    gui.bring_to_front()
    player.opened = gui
end