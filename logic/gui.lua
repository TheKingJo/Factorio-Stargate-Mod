local glib = require("__glib__/glib")
local guis = {}
local handlers = {}

---@param name string
---@param caption LocalisedString
---@param events? {frame: GuiEventHandler?, button: GuiEventHandler?}
function guis.default_frame(name, caption, events)
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

function handlers.default_close(event)
    event.element.destroy()
end

function handlers.default_close_button(event)
    event.element.parent.parent.destroy()
end

glib.register_handlers(handlers)

return guis