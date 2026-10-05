local simulations = {}

simulations.tipsAndTricks = {
    init = [[
        player = game.simulation.create_test_player{name = "big k"}
        player.teleport({-4, 0.5})
        game.simulation.camera_player = player
        game.simulation.camera_position = {0, 0.5}
        game.simulation.camera_player_cursor_position = player.position
        player.character.direction = defines.direction.east

        step_1 = function()
            biter = game.surfaces[1].create_entity{name = "medium-biter", position = {12 + (math.random() * 2), -4 + (math.random() * 4)}}
            biter.speed = 0.05
            biter.commandable.set_command
            {
                type = defines.command.attack,
                target = player.character
            }

            tree = game.surfaces[1].create_entity{name = "tree-02", position = {4, 2.5}}

            local count = 60
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                step_2()
            end)
        end

        step_2 = function()
            local rand_x = -1.5
            local rand_y = -1
            local position = {0.5 * ((biter.position.x + rand_x) + player.position.x), 0.5 * ((biter.position.y + rand_y) + player.position.y)}
            player.clear_items_inside()
            player.insert("pistol")
            player.insert("piercing-rounds-magazine")
            player.force.set_ammo_damage_modifier("bullet", 0.5)

            script.on_nth_tick(1, function()
                if not biter.valid then
                    step_3()
                    return
                end
                if game.simulation.move_cursor({position = position}) then
                    player.shooting_state = {state  = defines.shooting.shooting_enemies, position = position}
                end
            end)
        end

        step_3 = function()
            local count = 60
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end

                if game.simulation.move_cursor({position = tree.position}) then
                    step_4()
                end
            end)
        end

        step_4 = function()
            local count = 30
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                if not tree.valid then
                    step_5()
                end
                player.shooting_state = {state  = defines.shooting.shooting_selected, position = game.simulation.camera_player_cursor_position}
            end)
        end

        step_5 = function()
            local count = 30
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                if game.simulation.move_cursor({position = player.position}) then
                    reset()
                end
            end)
        end

        reset = function()
            local count = 30
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                start()
            end)
        end

        start = function()
            local count = 30
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                step_1()
            end)
        end

        start()
    ]]
}
simulations.iris = {
    init = [[
        game.simulation.camera_position = {0, -3.5}
        game.simulation.camera_zoom = 1.3
        surface = game.surfaces[1]
        local iris = surface.create_entity{
            name = "kj_stargate_iris",
            force = "neutral",
            position = {0, -2},
        }
        rendering.draw_sprite{
            sprite = "kj_stargate_base_sprite_s",
            target = {0, -1.9},
            surface = surface,
            render_layer = "object",
        }
        rendering.draw_sprite{
            sprite = "kj_stargate_base_sprite_s_background",
            target = {0, -2.5},
            surface = surface,
            render_layer = "object",
        }

        step_1 = function()
            iris.power_switch_state = true
            local count = 5*60
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                step_2()
            end)
        end

        step_2 = function()
            iris.power_switch_state = false
            local count = 5*60
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                start()
            end)
        end


        reset = function()
            local count = 120
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                start()
            end)
        end

        start = function()
            local count = 30
            script.on_nth_tick(1, function()
                if count > 0 then count = count - 1 return end
                step_1()
            end)
        end
        start()
    ]]
}

return simulations