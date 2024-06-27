import "random" for Random
import "Save" for Save
import "Constants" for Constants
import "Game" for Game, Cloud
import "Controls" for Controls

class Menu is Level {
    // Menus
    static MENU_MAIN { 0 }
    static MENU_SETTINGS { 1 }
    static MENU_STATS { 2 }

    // Cursor positions
    static MENU_MAIN_PLAY { 0 }
    static MENU_MAIN_SETTINGS { 1 }
    static MENU_MAIN_STATS { 2 }
    static MENU_MAIN_QUIT { 3 }

    static MENU_SETTINGS_FULLSCREEN { 0 }
    static MENU_SETTINGS_VOLUME { 1 }
    static MENU_SETTINGS_UI_SCALE { 2 }
    static MENU_SETTINGS_SHAKE_INTENSITY { 3 }
    static MENU_SETTINGS_BACK { 4 }

    static MENU_STATS_BACK { 0 }

    construct new() {
        _rng = Random.new(70)
        _clouds_foreground = []
        _clouds_background = []
        _titlecard_time = 0
        _cursor = 0
        _menu = 0
        _fade_out = 2.5
        _fade_out_start = _fade_out
        _play = false
        _ui_scale = Save.ui_scale
    }
    rng { _rng }

    reset_clouds() {
        _clouds_foreground.clear()
        _clouds_background.clear()
        for (i in 1..(Constants.CLOUD_COUNT / 4)) {
            _clouds_background.add(Cloud.new(_rng, _background_camera.width, _background_camera.height))
            _clouds_foreground.add(Cloud.new(_rng, _background_camera.width, _background_camera.height))
        }
    }

    create() {
        super.create()
        _ui_scale = _ui_scale
        _background_camera = Camera.new()
        _ui_camera = Camera.new()
        _background_camera.width = Renderer.window_width / 2
        _background_camera.height = Renderer.window_height / 2
        _background_camera.w_on_screen = Renderer.window_width
        _background_camera.h_on_screen = Renderer.window_height
        _background_camera.update()
        reset_clouds()
        _cursor_x = ((Renderer.window_width / 2) - (Assets.tex_mainmenu.width * 0.5 * _ui_scale)) + (35 * _ui_scale)
        _cursor_y = (Renderer.window_height - (Assets.tex_mainmenu.height * _ui_scale) - (Renderer.window_height * 0.2)) + (12 * _ui_scale)
        _menu_effect = Audio.play(Assets.aud_menueffect, false, Save.volume, Save.volume)
    }

    pre_frame() {
        super.pre_frame()
        
        // Camera
        _ui_camera.width = Renderer.window_width
        _ui_camera.height = Renderer.window_height
        _ui_camera.w_on_screen = Renderer.window_width
        _ui_camera.h_on_screen = Renderer.window_height
        _ui_camera.update()
        _background_camera.width = Renderer.window_width / 2
        _background_camera.height = Renderer.window_height / 2
        _background_camera.w_on_screen = Renderer.window_width
        _background_camera.h_on_screen = Renderer.window_height
        _background_camera.update()
    }

    bounce(time) {
        time = time * 3
        if (time >= 2.348 * 3) {
            return 0
        } else if (time < 2 * 3) {
            return (0.2 * ((time - 8) * (time - 8).sin).abs)
        }
        return (-3 * ((time / 3) - 2).pow(2)) + 0.3639
    }

    draw_tiling_background(texture, parallax) {
        var cx = 0
        var cy = 0
        var cwidth = 0
        var cheight = 0
        cx = Engine.time * 2
        cy = Engine.time
        cwidth = _ui_camera.width
        cheight = _ui_camera.height

        var tile_start_x = cx * parallax
        var tile_start_y = cy * parallax
        tile_start_x = (tile_start_x + (((cx - tile_start_x) / texture.width).floor * texture.width)) - texture.width
        tile_start_y = (tile_start_y + (((cy - tile_start_y) / texture.height).floor * texture.height)) - texture.height
        var horizontal = (cwidth / texture.width).ceil + 1
        var vertical = (cheight / texture.height).ceil + 1
        for (y in 0..vertical) {
            for (x in 0..horizontal) {
                Renderer.draw_texture(texture, tile_start_x + (x * texture.width), tile_start_y + (y * texture.height))
            }
        }
    }

    move_cursor_to(x, y) {
        _cursor_x = _cursor_x + ((x - _cursor_x) * 0.2)
        _cursor_y = _cursor_y + ((y - _cursor_y) * 0.2)
    }

    draw_bar(x, y, percent) {
        Renderer.draw_texture(Assets.tex_menubar, x, y, _ui_scale, _ui_scale, 0, 0, 0)
        Renderer.colour_mod = "#346270"
        Renderer.draw_rectangle(x + (_ui_scale * 2), y + (_ui_scale * 2), 69 * _ui_scale * percent, 9 * _ui_scale, 0, 0, 0)
        Renderer.colour_mod = [1, 1, 1, 1]
    }

    process_menu(ignore_frame) {
        var texture = _menu == Menu.MENU_MAIN ? Assets.tex_mainmenu : Assets.tex_settings
        var x = (Renderer.window_width / 2) - (texture.width * 0.5 * _ui_scale)
        var y = Renderer.window_height - (texture.height * _ui_scale) - (Renderer.window_height * 0.2)

        if (_menu == Menu.MENU_MAIN) {
            if (!ignore_frame && Controls.menu_down) {
                _cursor = _cursor == (Menu.MENU_MAIN_QUIT) ? 0 : _cursor + 1
                Audio.play(Assets.aud_menucursor, false, Save.volume, Save.volume)
            } else if (!ignore_frame && Controls.menu_up) {
                _cursor = _cursor == 0 ? Menu.MENU_MAIN_QUIT : (_cursor - 1)
                Audio.play(Assets.aud_menucursor, false, Save.volume, Save.volume)
            }
            if (!ignore_frame && Controls.confirm) {
                Audio.play(Assets.aud_menuselect, false, Save.volume, Save.volume)
                if (_cursor == Menu.MENU_MAIN_PLAY) {
                    return true
                } else if (_cursor == Menu.MENU_MAIN_SETTINGS) {
                    _menu = Menu.MENU_SETTINGS
                    _cursor = 0
                } else if (_cursor == Menu.MENU_MAIN_STATS) {
                    _menu = Menu.MENU_STATS
                } else if (_cursor == Menu.MENU_MAIN_QUIT) {
                    Save.save()
                    Engine.quit()
                }
            }

            Renderer.draw_texture(texture, x, y, _ui_scale, _ui_scale, 0, 0, 0)
            if (_cursor == Menu.MENU_MAIN_PLAY) {
                move_cursor_to(x + (35 * _ui_scale * 0.5), y + (12 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            } else if (_cursor == Menu.MENU_MAIN_SETTINGS) {
                move_cursor_to(x + (-32 * _ui_scale * 0.5), y + (63 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            } else if (_cursor == Menu.MENU_MAIN_STATS) {
                move_cursor_to(x + (18 * _ui_scale * 0.5), y + (112 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            } else if (_cursor == Menu.MENU_MAIN_QUIT) {
                move_cursor_to(x + (47 * _ui_scale * 0.5), y + (159 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            }
        } else if (_menu == Menu.MENU_SETTINGS) {
            if (!ignore_frame && Controls.menu_down) {
                _cursor = _cursor == (Menu.MENU_SETTINGS_BACK) ? 0 : _cursor + 1
                Audio.play(Assets.aud_menucursor, false, Save.volume, Save.volume)
            } else if (!ignore_frame && Controls.menu_up) {
                _cursor = _cursor == 0 ? Menu.MENU_SETTINGS_BACK : (_cursor - 1)
                Audio.play(Assets.aud_menucursor, false, Save.volume, Save.volume)
            }
            if (!ignore_frame && Controls.confirm) {
                Audio.play(Assets.aud_menuselect, false, Save.volume, Save.volume)
                if (_cursor == Menu.MENU_SETTINGS_FULLSCREEN) {
                    Renderer.fullscreen = !Renderer.fullscreen
                    Save.fullscreen = Renderer.fullscreen
                    _background_camera.width = Renderer.window_width / 2
                    _background_camera.height = Renderer.window_height / 2
                    _background_camera.w_on_screen = Renderer.window_width
                    _background_camera.h_on_screen = Renderer.window_height
                    reset_clouds()
                } else if (_cursor == Menu.MENU_SETTINGS_VOLUME) {
                    Save.volume = Save.volume + 0.1
                    if (Save.volume > 1) {
                        Save.volume = 0
                    }
                } else if (_cursor == Menu.MENU_SETTINGS_SHAKE_INTENSITY) {
                    Save.shake_modifier = Save.shake_modifier + 0.25
                    if (Save.shake_modifier > 2.1) {
                        Save.shake_modifier = 0
                    }
                } else if (_cursor == Menu.MENU_SETTINGS_UI_SCALE) {
                    Save.ui_scale = Save.ui_scale + 1
                    if (Save.ui_scale == 4) {
                        Save.ui_scale = 1
                    }
                } else if (_cursor == Menu.MENU_SETTINGS_BACK) {
                    _menu = Menu.MENU_MAIN
                    _cursor = 0
                }
            }
            Renderer.draw_texture(texture, x, y, _ui_scale, _ui_scale, 0, 0, 0)
            draw_bar(x + (_ui_scale * 162), y + (_ui_scale * 32), Save.volume)
            draw_bar(x + (_ui_scale * 172), y + (_ui_scale * 56), Save.ui_scale / 3)
            draw_bar(x + (_ui_scale * 165), y + (_ui_scale * 81), Save.shake_modifier / 2)
            if (_cursor == Menu.MENU_SETTINGS_FULLSCREEN) {
                move_cursor_to(x + (-38 * _ui_scale * 0.5), y + (17 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            } else if (_cursor == Menu.MENU_SETTINGS_VOLUME) {
                move_cursor_to(x + (43 * _ui_scale * 0.5), y + (66 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            } else if (_cursor == Menu.MENU_SETTINGS_UI_SCALE) {
                move_cursor_to(x + (22 * _ui_scale * 0.5), y + (112 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            } else if (_cursor == Menu.MENU_SETTINGS_SHAKE_INTENSITY) {
                move_cursor_to(x + (34 * _ui_scale * 0.5), y + (161 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            } else if (_cursor == Menu.MENU_SETTINGS_BACK) {
                move_cursor_to(x + (81 * _ui_scale * 0.5), y + (210 * _ui_scale * 0.5))
                Renderer.draw_texture(Assets.tex_menucursor, _cursor_x, _cursor_y, _ui_scale, _ui_scale, 0, 0, 0)
            }
        } else if (_menu == Menu.MENU_STATS) {
            if (!ignore_frame && Controls.confirm) {
                Audio.play(Assets.aud_menuselect, false, Save.volume, Save.volume)
                _menu = Menu.MENU_MAIN
                _cursor = 0
            }
            // TODO: Draw stats
        }
        return false
    }

    update() {
        super.update()
        Renderer.lock_cameras(_ui_camera)
        var add = Engine.delta
        if (Controls.confirm) {
            add = 2.348
            if (_titlecard_time < 2.348) {
                _menu_effect.stop()
            }
            if (_play) {
                _fade_out = 0
            }
        }
        var ignore_frame = false
        if (add + _titlecard_time > 2.348 && _titlecard_time < 2.348) {
            // The moment the title card is done
            ignore_frame = true
        }
        _titlecard_time = _titlecard_time + add

        if (Renderer.fullscreen) {
            _ui_scale = Save.ui_scale + 1
        } else {
            _ui_scale = Save.ui_scale
        }

        // Background
        draw_tiling_background(Assets.tex_background, 8)

        Renderer.lock_cameras(_background_camera)
        for (cloud in _clouds_background) {
            cloud.draw(false)
        }
        Renderer.lock_cameras(_ui_camera)

        var middle_x = Renderer.window_width / 2
        var middle_y = Renderer.window_height / 2
        Renderer.draw_texture(Assets.tex_titlecard, middle_x - (Assets.tex_titlecard.width * _ui_scale * 0.5), (Renderer.window_height * 0.05) - (bounce(_titlecard_time) * _ui_scale * 100), _ui_scale, _ui_scale, 0, 0, 0)

        // Draws the menu buttons
        if (_titlecard_time > 2.348) {
            if (process_menu(ignore_frame || _play)) {
                _play = true
            }
        }

        Renderer.lock_cameras(_background_camera)
        for (cloud in _clouds_foreground) {
            cloud.draw(false)
        }
        Renderer.lock_cameras(_ui_camera)

        // Draw the fade out
        if (_play) {
            Renderer.colour_mod = [0, 0, 0, 1]
            Renderer.draw_rectangle(0, 0, Renderer.window_width, Renderer.window_height - Renderer.window_height * bounce(Math.lerp((1 - (_fade_out / _fade_out_start)), 0, 2.6)), 0, 0, 0)
            Renderer.colour_mod = [1, 1, 1, 1]
            _fade_out = _fade_out - Engine.delta
            if (_fade_out <= 0) {
                Save.save()
                Engine.switch_level(Game.new())
            }
        }

        // Fullscreen
        if (Keyboard.key(Keyboard.KEY_LALT) && Keyboard.key_pressed(Keyboard.KEY_RETURN)) {
            Renderer.fullscreen = !Renderer.fullscreen
            Save.fullscreen = Renderer.fullscreen
            _background_camera.width = Renderer.window_width / 2
            _background_camera.height = Renderer.window_height / 2
            _background_camera.w_on_screen = Renderer.window_width
            _background_camera.h_on_screen = Renderer.window_height
            reset_clouds()
        }
    }

    destroy() {
        Save.save()
        super.destroy()
    }
}