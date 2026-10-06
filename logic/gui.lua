local glib = require("__glib__/glib")
local guis = {}
local handlers = {}
util = require("utils")

---@param name string
---@param caption LocalisedString
---@param events? {frame: GuiEventHandler?, button: GuiEventHandler?}
function guis.dhd_frame_new(events)
    return {
        args = {type = "frame", name = "dhd", direction = "vertical"},
        _closed = events and events.frame or handlers.default_close,
        children = {{
            args = {type = "flow", name = "header"},
            ref = false,
            drag_target = "dhd",
            children = {{
                args = {type = "label", caption = {"dhd"}, style = "frame_title", ignored_by_interaction = true},
            }, {
                args = {type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true},
                style_mods = {horizontally_stretchable = true, height = 24},
            }, {
                args = {type = "sprite-button", style = "close_button", sprite = "utility/close"},
                _click = events and events.button or handlers.default_close_button,
            }},
        }, {
            args = {type = "frame", style = "inside_shallow_frame"},
            children = {{
                args = {type = "flow", direction = "vertical"},
                style_mods = {vertical_spacing = 0},
                children = {{
                    args = {type = "frame", style = "filter_frame"},
                    style_mods = {natural_height = 224},
                    children = {{
                        args = {type = "scroll-pane", style = "deep_slots_scroll_pane"},
                        style_mods = {minimal_width = 400, minimal_height = 200},
                        children = {{
                            args = {type = "table", name = "glyphs", column_count = 10},
                        }},
                    }},
                }},
            }}
        }}
    }
end

function guis.dhd_letter(letter, dhdSurface, dhdID, toggled) --letter
    return {
        args = {type = "sprite-button", name = letter, sprite = "kj_sg_glyph_"..letter,
            tags = {surface = dhdSurface, dhdID = dhdID, letter = letter}
        },
        elem_mods = {toggled = toggled or false},
        _click = handlers.dhd_letter_click,
    }
end

function guis.gdo_frame(events)
    return {
        args = {type = "frame", name = "gdo", direction = "vertical"},
        _closed = events and events.frame or handlers.default_close,
        children = {
            {
                args = {type = "flow", name = "header"},
                ref = false,
                drag_target = "gdo",
                children = {{
                    args = {type = "label", caption = {"gdo"}, style = "frame_title", ignored_by_interaction = true},
                }, {
                    args = {type = "sprite-button", style = "close_button", sprite = "utility/close"},
                    _click = events and events.button or handlers.default_close_button,
                }},
            },
            {
                args = {type = "frame", style = "inside_shallow_frame"},
                children = {{
                    args = {type = "flow", direction = "vertical"},
                    style_mods = {vertical_spacing = 10},
                    children = {{
                        args = {type = "frame", style = "filter_frame"},
                            style_mods = {natural_height = 50},
                        children = {{
                            args = {type = "scroll-pane", style = "deep_scroll_pane"},
                            style_mods = {horizontally_stretchable = true},
                            children = {{
                                args = {type = "flow", name = "gates", direction = "vertical"},
                                style_mods = {horizontally_stretchable = true},
                            }},
                        }},
                    }},
                }}
            }
        }
    }
end

function guis.gdo_gate(gateSurface, gateID, iris, events) --gdo_gate
    local state = "on"
    if iris and iris.power_switch_state == true then
        state = "iris"
    end

    return {
        args = {type = "frame", name = "gdo_gate", style = "bordered_frame", tags = {irisID = gateID}},
        style_mods = {horizontal_align = "left", horizontally_stretchable = true},
        children = {
            {
                args = {type = "flow", direction = "horizontal"},
                style_mods = {horizontally_stretchable = true},
                children = {{
                        args = {type = "sprite", style = "image", sprite = "kj_sg_gate_"..state},
                        style_mods = {vertical_align = "center", right_padding = 10},
                    }, {
                        args = {type = "label", style = "frame_title",
                        caption = {"", {"gdoGui1"}, {"space-location-name."..gateSurface}, }},
                        style_mods = {vertical_align = "center"},
                    }, {
                        args = {type = "textfield", name = "code", style = "stretchable_textfield"},
                    }, {
                        args = {type = "sprite-button", style = "item_and_count_select_confirm", sprite = "utility/enter", tooltip = {"gdoGui4"}},
                        _click = events and events.button or handlers.gdo_send_code,
                    }
                }
            }
        },
    }
end

function guis.gdo_iris_frame(irisID, events) --gdo_iris
    return {
        args = {type = "frame", name = "gdo_iris", direction = "vertical", anchor = {
            gui = defines.relative_gui_type.power_switch_gui,
            position = defines.relative_gui_position.left,
        }, tags = {irisID = irisID}},
        style_mods = {natural_width = 200},
        children = {
            {
                args = {type = "flow", name = "header"}, ref = false,
                children = {{
                        args = {type = "label", caption = {"gdoGuiIris1"}, style = "frame_title", ignored_by_interaction = true},
                    }, {
                        args = {type = "sprite-button", style = "item_and_count_select_confirm", sprite = "utility/add", tooltip = {"gdoGuiIris3"}},
                        _click = events and events.button or handlers.gdo_add_code,
                    }
                },
            },
            {
                args = {type = "frame", style = "inside_shallow_frame"},
                children = {{
                    args = {type = "flow", direction = "vertical"},
                    style_mods = {vertical_spacing = 10},
                    children = {{
                        args = {type = "frame", style = "filter_frame"},
                        style_mods = {horizontally_stretchable = true},
                        children = {{
                            args = {type = "flow", name = "gdos", direction = "vertical", tags = {irisID = irisID}},
                            style_mods = {horizontally_stretchable = true},
                        }},
                    }},
                }}
            }
        }
    }
end

function guis.gdo_code(irisID, code, events) --ABDEF
    return {
        args = {type = "flow", name = code, direction = "horizontal", tags = {irisID = irisID, code = code}},
        style_mods = {horizontally_stretchable = true},
        children = {{
                args = {type = "textfield", text = code, style = "stretchable_textfield"},
                _text_changed = events and events.button or handlers.gdo_change_code,
            }, {
                args = {type = "sprite-button", style = "close_button", sprite = "utility/close", tooltip = {"gdoGuiIris2"}},
                _click = events and events.button or handlers.gdo_delete_code,
            }
        }
    }
end

function handlers.default_close(event)
    event.element.destroy()
end

function handlers.default_close_button(event)
    event.element.parent.parent.destroy()
end

function handlers.gdo_send_code(event)
    local code = event.element.parent.code.text
    if code == "" then return end
    local irisID = event.element.parent.parent.tags.irisID
    local irisedGate = storage.irisedGates[tonumber(irisID)]

    if irisedGate.gdos[code] == true then
        local section = irisedGate.childs.signalSender.get_control_behavior().get_section(1)
        section.set_slot(3, {
            value = {
                type = "entity",
                name = sgNames.iris,
                quality = qualities[1],
                comparator = "=",
            },
            min = -1,
        })
        irisedGate:SetIris(false)
        GDOTriggered({
            prototype_name = "kj_stargate_gdo",
            player_index = event.player_index,
        }, true)
    end
end

function handlers.gdo_add_code(event)
    local irisID = event.element.parent.parent.tags.irisID
    local code, j = "", 1
    repeat
        for i = 1, 6 do
            local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            local pos = math.random(1, #chars)
            code = code..chars:sub(pos, pos)
        end
        j = j + 1
    until storage.irisedGates[tonumber(irisID)].gdos[code] == nil or j == 1000

    storage.irisedGates[tonumber(irisID)].gdos[code] = true

    RefreshAllGDOIris({add = code, player_index = event.player_index})
end

function handlers.gdo_change_code(event)
    local irisID = event.element.parent.tags.irisID
    local oldCode = event.element.parent.name
    local newCode = event.text

    storage.irisedGates[tonumber(irisID)].gdos[oldCode] = nil
    storage.irisedGates[tonumber(irisID)].gdos[newCode] = true

    RefreshAllGDOIris({change = {oldCode, newCode}, player_index = event.player_index})
end

function handlers.gdo_delete_code(event)
    local irisID = event.element.parent.tags.irisID
    local code = event.element.parent.name
    storage.irisedGates[tonumber(irisID)].gdos[code] = nil

    RefreshAllGDOIris({delete = code, player_index = event.player_index})
end

function handlers.dhd_letter_click(event)
    if event.button == defines.mouse_button_type.left then
        local element = event.element
        local dhdSurface, dhdID, char = element.tags.surface, element.tags.dhdID, element.tags.letter
        local dhd = util.findIDInGlobal("dhd", dhdSurface, dhdID)

        if dhd then
            local gate = dhd.stargate
            if char == "connect" then
                if gate.active == false then
                    util.playSoundOnSurface(gate.entity.surface, gate.pos, "kj_stargate_dhdc")
                    dhd:Connect(dhdSurface)
                else
                    dhd:Disconnect()
                end
            elseif gate.active == false and gate.safeToTravel == false then
                if element.toggled == false then --clicked letter button
                    if #dhd.address < 7 then
                        element.toggled = not element.toggled
                        util.playSoundOnSurface(dhd.entity.surface, gate.pos, util.randomSound("kj_stargate_dhd", 7))
                        dhd.glyphs[(#dhd.address or 0) + 1].animation_offset = charLookup[char]
                        dhd.addressLetters[char] = true
                        table.insert(dhd.address, char)
                        gate.chevrons.animation_offset = gate.chevrons.animation_offset + 1
                    end
                else --unclicked letter button
                    local index = util.deleteFromITable(dhd.address, char)
                    if dhd.glyphs[index] == nil then
                        dhd:CloseGUIs()
                        return
                    end
                    dhd.glyphs[index].destroy() --prüfen ob existiert, und wenn nicht GUI schließen
                    element.toggled = not element.toggled
                    util.playSoundOnSurface(gate.entity.surface, gate.pos, util.randomSound("kj_stargate_dhd", 7))
                    dhd.addressLetters[char] = nil
                    table.remove(dhd.glyphs, index)
                    table.insert(dhd.glyphs, rendering.draw_animation{
                        animation = "kj_stargate_dhd_"..dhd.entity.direction,
                        animation_speed = 0,
                        target = dhd.pos,
                        surface = dhd.entity.surface,
                        render_layer = "object",
                    })
                    gate.chevrons.animation_offset = math.max(gate.chevrons.animation_offset - 1, 0)
                end
                dhd:TrackIdling()
            end
        else
            game.print("dhd not found")
        end
    end
end

glib.register_handlers(handlers)

return guis