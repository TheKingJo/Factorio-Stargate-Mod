if script.active_mods["gvv"] then require("__gvv__.gvv")() end
util = require("utils")
require("util")
require("logic.gate")
require("logic.events")
require("logic.tick")
require("logic.init")
sg_guis = require("logic.gui")
mod_gui = require("mod-gui")
glib = require("__glib__/glib")

if script.active_mods["kj_vehicles"] then
    kj_compat = require("__kj_vehicles__.utils")
end
--seed: 163867536

commands.add_command("printAddress", nil, function(command)
    if command.player_index == nil then return end
    local surface = command.parameter

    if surface ~= nil then
        if storage.addresses[surface] ~= nil then
            game.print("Address of "..surface..": "..util.getSignalFromChar(storage.addresses[surface], true))
        end
    else
        for surface, address in pairs(storage.addresses) do
            game.print("Address of "..surface..": "..util.getSignalFromChar(address, true))
        end
    end
end)

script.on_event(defines.events.on_built_entity, OnBuilt)
script.on_event(defines.events.on_robot_built_entity, OnBuilt)

script.on_load(OnLoad)
script.on_configuration_changed(initStorage)

script.on_event(defines.events.on_player_mined_entity, OnRemoved)
script.on_event(defines.events.on_robot_mined_entity, OnRemoved)
script.on_event(defines.events.on_entity_died, OnRemoved)
script.on_event(defines.events.on_player_driving_changed_state, OnPlayerEnteredVehicle)

script.on_event(defines.events.on_entity_damaged , OnDamaged, {
    {filter = "name", name = "kj_stargate_transferArea"},
    {filter = "name", name = "kj_stargate_transferArea_signaled", mode = "or"},
    {filter = "name", name = "kj_dhd", mode = "or"},
    {filter = "name", name = "kj_stargate_auto_gen", mode = "or"},
    {filter = "name", name = "kj_dhd_auto_gen", mode = "or"},
})

script.on_event(defines.events.on_tick, OnTick)
script.on_nth_tick(60, OnNthTickTasks)
script.on_nth_tick(10, OnNthTickSGates)
script.on_nth_tick( 6, OnNthTickSGateDialing)
script.on_nth_tick( 2, OnNthTickPlayer)

script.on_event(defines.events.on_surface_created,
    function(event)
        local surface = game.surfaces[event.surface_index]
        addAddressToGlobal(surface, generateAdress(surface))
    end
)

script.on_event(defines.events.on_gui_opened, GuiOpened)
script.on_event(defines.events.on_chunk_generated, Chunk)

script.on_init(OnInit)
