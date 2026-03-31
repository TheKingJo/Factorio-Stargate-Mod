local glib = require("__glib__/glib")
local guis = {}
local handlers = {}
util = require("utils")

---@param name string
---@param caption LocalisedString
---@param events? {frame: GuiEventHandler?, button: GuiEventHandler?}
function guis.dhd_frame(name, caption, events)
    return {
        args = {type = "frame", name = name, direction = "vertical"},
        _closed = events and events.frame or handlers.default_close,
        children = {{
            args = {type = "flow", name = "header"},
            ref = false,
            drag_target = name,
            children = {{
                args = {type = "label", caption = caption, style = "frame_title", ignored_by_interaction = true},
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
                            args = {type = "table", name = "stargates", column_count = 1},
                        }},
                    }},
                }},
            }}
        }}
    }
end

function guis.dhd_frame_new(name, caption, events)
    return {
        args = {type = "frame", name = name, direction = "vertical"},
        _closed = events and events.frame or handlers.default_close,
        children = {{
            args = {type = "flow", name = "header"},
            ref = false,
            drag_target = name,
            children = {{
                args = {type = "label", caption = caption, style = "frame_title", ignored_by_interaction = true},
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
                            args = {type = "table", name = "stargates", column_count = 10},
                        }},
                    }},
                }},
            }}
        }}
    }
end

function guis.dhd_element(sgSurface, sgID, dhdSurface, dhdID)--(name1.id1).(name2.id2)
    local name = "("..sgSurface.."."..sgID..").("..dhdSurface.."."..dhdID..")"
    return {
        args = {type = "choose-elem-button", name =  name, elem_type = "space-location", ["space-location"] = sgSurface},
        elem_mods = {locked = true},
        _click = handlers.planet_click,
    }
end

function guis.dhd_letter(letter, dhdSurface, dhdID) --nauvis.69.E
    local name = dhdSurface.."."..dhdID.."."..letter
    return {
        args = {type = "sprite-button", name = name, sprite = "kj_sg_glyph_"..letter},
        _click = handlers.letter_click,
    }
end

function handlers.default_close(event)
    event.element.destroy()
end

function handlers.default_close_button(event)
    event.element.parent.parent.destroy()
end

function handlers.planet_click(event)
    if event.button == defines.mouse_button_type.left then
        local sgSurface, dhdSurface, sgId, dhdId = util.splitNameId(event.element.name)
        local stargate = util.findIDInGlobal("stargate", sgSurface, sgId)
        local dhd = util.findIDInGlobal("dhd", dhdSurface, dhdId)
        if dhd and dhd.stargate then
            if stargate then
                if stargate.dhd == nil or (stargate.dhd ~= nil and stargate.dhd.id ~= dhdId) then
                    dhd.stargate:Connect(stargate)
                else
                    game.print("Cannot connect to itself!")
                end
            else
                dhd.stargate:Disconnect()
            end
        end
    end
end

function handlers.letter_click(event)
    if event.button == defines.mouse_button_type.left then
        local element = event.element
        local dhdSurface, dhdID, char = util.splitNameId2(element.name)
        local dhd = util.findIDInGlobal("dhd", dhdSurface, dhdID)

        if dhd then
            local gate = dhd.stargate
            if #dhd.address < 7 then
                if char ~= "connect" then
                    if element.toggled == false then
                        element.toggled = not element.toggled
                        dhd.glyphs[(#dhd.address or 0) + 1].animation_offset = charLookup[char]
                        table.insert(dhd.address, char)
                        util.playSoundOnSurface(gate.entity.surface, gate.entity.position, util.randomSound("kj_stargate_dhd", 7))
                        gate.chevrons.animation_offset = gate.chevrons.animation_offset + 1
                    end
                end
            else
                if char == "connect" then
                    if gate.active ~= true then
                        game.print("Trying to establish connection")
                        util.playSoundOnSurface(gate.entity.surface, gate.entity.position, "kj_stargate_dhdc")
                        dhd:Connect(dhdSurface)
                    else
                        dhd:Disconnect()
                    end
                    element.parent.parent.parent.parent.parent.parent.destroy()
                    return
                end
            end
        else
            game.print("dhd not found")
        end
    end
end

--util.register_handlers(handlers)
glib.register_handlers(handlers)

return guis