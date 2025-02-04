import "CameraManager" for CameraManager
import "random" for Random
import "Save" for Save, Items
import "Constants" for Constants
import "Game" for Game, Cloud
import "Between" for Between
import "Controls" for Controls
import "TextMenu" for TextMenu, MenuOption

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
        _music = null
        _ui_scale = Save.ui_scale
        _showing_help = false
    }
    rng { _rng }

    reset_clouds() {
        _clouds_foreground.clear()
        _clouds_background.clear()
        for (i in 1..(Constants.CLOUD_COUNT / 4)) {
            _clouds_background.add(Cloud.new(_rng, _background_camera.width, _background_camera.height, true))
            _clouds_foreground.add(Cloud.new(_rng, _background_camera.width, _background_camera.height, false))
        }
    }

    create() {
        super.create()
        CameraManager.setup()
        Renderer.colour_mod = [1, 1, 1, 1]
        Renderer.hide_cursor = true
        _time = 0
        _ui_scale = _ui_scale
        _background_camera = CameraManager.menu_background_camera
        _ui_camera = CameraManager.menu_camera
        _background_camera.x = 0
        _background_camera.y = 0
        _background_camera.width = Renderer.window_width / 4
        _background_camera.height = Renderer.window_height / 4
        _background_camera.w_on_screen = Renderer.window_width
        _background_camera.h_on_screen = Renderer.window_height
        _background_camera.update()
        reset_clouds()
        _cursor_x = 0//((Renderer.window_width / 2) - (Assets.tex_mainmenu.width * 0.5 * _ui_scale)) + (35 * _ui_scale)
        _cursor_y = 0//(Renderer.window_height - (Assets.tex_mainmenu.height * _ui_scale) - (Renderer.window_height * 0.2)) + (12 * _ui_scale)
        _menu_effect = Audio.play(Assets.aud_menueffect, false, Save.volume, Save.volume)

        // Create the menu options
        _text_menu = TextMenu.new()
        var top = _text_menu.top_menu
        var options = _text_menu.add_menu("options")
        var stats = _text_menu.add_menu("stats")
        var help = _text_menu.add_menu("help")

        // Top level
        var play_fn = Fn.new {
            Save.oops_all_wizards = false
            Save.total_runs = Save.total_runs + 1
            _play = true
        }
        var oopsallwizards_fn = Fn.new {
            Save.oops_all_wizards = true
            _play = true
        }
        var options_fn = Fn.new {
            _text_menu.set_menu("options")
        }
        var stats_fn = Fn.new {
            _showing_stats = true
            _text_menu.set_menu("stats")
        }
        var help_fn = Fn.new {
            _showing_help = true
            _text_menu.set_menu("help")
        }
        var quit_fn = Fn.new {
            Engine.quit()
        }
        top.add_option(MenuOption.new("Play", play_fn, MenuOption.TYPE_NONE))
        if (Save.beaten_game) {
            top.add_option(MenuOption.new("Play+", oopsallwizards_fn, MenuOption.TYPE_NONE))
        }
        top.add_option(MenuOption.new("Options", options_fn, MenuOption.TYPE_NONE))
        top.add_option(MenuOption.new("Stats", stats_fn, MenuOption.TYPE_NONE))
        top.add_option(MenuOption.new("Help", help_fn, MenuOption.TYPE_NONE))
        top.add_option(MenuOption.new("Quit", quit_fn, MenuOption.TYPE_NONE))

        // Stats
        var back_to_menu_fn = Fn.new {
            _showing_stats = false
            _text_menu.set_menu("top")
        }
        stats.add_option(MenuOption.new_hidden("Back", back_to_menu_fn, MenuOption.TYPE_NONE))

        // Help
        var back_to_menu_help_fn = Fn.new {
            _showing_help = false
            _text_menu.set_menu("top")
        }
        help.add_option(MenuOption.new_hidden("Back", back_to_menu_help_fn, MenuOption.TYPE_NONE))

        // Options
        var volume_fn = Fn.new { |volume| 
            Save.volume = volume
            _music.update(true, Save.volume, Save.volume)
        }
        var fullscreen_fn = Fn.new {
            Renderer.fullscreen = !Renderer.fullscreen
            Save.fullscreen = Renderer.fullscreen
            _background_camera.width = Renderer.window_width / 4
            _background_camera.height = Renderer.window_height / 4
            _background_camera.w_on_screen = Renderer.window_width
            _background_camera.h_on_screen = Renderer.window_height
            reset_clouds()
        }
        var shake_intensity_fn = Fn.new { |intensity|
            Save.shake_modifier = intensity
            if (Save.shake_modifier > 2.1) {
                Save.shake_modifier = 0
            }
        }
        var ui_scale_fn = Fn.new {
            Save.ui_scale = Save.ui_scale + 1
            if (Save.ui_scale == 4) {
                Save.ui_scale = 1
            }
        }
        var crt_filter_fn = Fn.new { |enabled|
            Save.crt_effect = enabled
        }
        options.add_option(MenuOption.new("Volume", volume_fn, MenuOption.TYPE_SLIDER, Save.volume))
        options.add_option(MenuOption.new("Fullscreen", fullscreen_fn, MenuOption.TYPE_NONE))
        options.add_option(MenuOption.new("Screen Shake", shake_intensity_fn, MenuOption.TYPE_SLIDER, Save.shake_modifier))
        options.add_option(MenuOption.new("UI Scale", ui_scale_fn, MenuOption.TYPE_NONE))
        options.add_option(MenuOption.new("CRT Shader", crt_filter_fn, MenuOption.TYPE_RADIO, Save.crt_effect))
        options.add_option(MenuOption.new("Back", back_to_menu_fn, MenuOption.TYPE_NONE))

        // The draw parameters for the menu
        _text_menu.x_offset = 8
        _text_menu.y_offset = 2
        _text_menu.align_x = TextMenu.ALIGN_CENTER
        _text_menu.align_y = TextMenu.ALIGN_CENTER
        _text_menu.finalize()

        // Build the stats screen
        _stats_surface = Surface.new(300, 13 * 10)
        Renderer.target = _stats_surface
        Renderer.colour_mod = [0, 0, 0, 0.2]
        Renderer.clear()
        Renderer.colour_mod = [1, 1, 1, 1]
        var advance = 13
        var x_advance = 150
        var y_stop = 0
        var x_stop = 1
        
        Renderer.draw_font_ext(Assets.fnt_monogram, "[#000000]Best Run", x_stop + 1, y_stop + 1)
        Renderer.draw_font_ext(Assets.fnt_monogram, "[#ffffff]Best Run", x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.highscore
        Renderer.draw_font(Assets.fnt_monogram, "Highscore: " + Save.highscore.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.best_run_parries
        Renderer.draw_font(Assets.fnt_monogram, "Parries: " + Save.best_run_parries.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.best_run_kills
        Renderer.draw_font(Assets.fnt_monogram, "Kills: " + Save.best_run_kills.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.best_run_highest_stage
        Renderer.draw_font(Assets.fnt_monogram, "Highest Stage: " + Save.best_run_highest_stage.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.best_run_props_destroyed
        Renderer.draw_font(Assets.fnt_monogram, "Props Destroyed: " + Save.best_run_props_destroyed.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.best_run_npcs_killed
        Renderer.draw_font(Assets.fnt_monogram, "NPCs Killed: " + Save.best_run_npcs_killed.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.best_run_axes_thrown
        Renderer.draw_font(Assets.fnt_monogram, "Axes Thrown: " + Save.best_run_axes_thrown.toString, x_stop, y_stop)
        y_stop = y_stop + advance

        var banner_current_x = x_stop
        var top_left = y_stop
        var item_start_x = 4
        var item_start_y = 4
        var banner_move_x = Assets.spr_itemdisplay.width / 3
        var spr_itemdisplay_scale_x = Assets.spr_itemdisplay.scale_x
        var spr_items_scale_x = Assets.spr_items.scale_x
        var spr_itemdisplay_scale_y = Assets.spr_itemdisplay.scale_y
        var spr_items_scale_y = Assets.spr_items.scale_y
        Assets.spr_itemdisplay.scale_x = 1/3
        Assets.spr_items.scale_x = 1/3
        Assets.spr_itemdisplay.scale_y = 1/3
        Assets.spr_items.scale_y = 1/3
        Renderer.draw_sprite(Assets.spr_itemdisplay, 0, banner_current_x, top_left)
        banner_current_x = banner_current_x + banner_move_x
        for (i in 0..Items.ITEM_COUNT - 1) {
            if (Save.best_run_items.item_count(i) > 0) {
                Renderer.draw_sprite(Assets.spr_itemdisplay, 1, banner_current_x, top_left)
                Renderer.draw_sprite(Assets.spr_items, i, banner_current_x + item_start_x, top_left + item_start_y)

                // If multiple items, draw an amount instead of the same item repeadetely
                if (Save.best_run_items.item_count(i) > 1) {
                    draw_digits(Save.best_run_items.item_count(i), banner_current_x - 4, top_left + 6, 1/3)
                }
                banner_current_x = banner_current_x + banner_move_x
            }
        }
        Renderer.draw_sprite(Assets.spr_itemdisplay, 2, banner_current_x, top_left)
        Assets.spr_itemdisplay.scale_x = spr_itemdisplay_scale_x
        Assets.spr_items.scale_x = spr_items_scale_x
        Assets.spr_itemdisplay.scale_y = spr_itemdisplay_scale_y
        Assets.spr_items.scale_y = spr_items_scale_y

        // Advance to next section
        y_stop = 0
        x_stop = x_advance

        Renderer.draw_font_ext(Assets.fnt_monogram, "[#000000]Totals", x_stop + 1, y_stop + 1)
        Renderer.draw_font_ext(Assets.fnt_monogram, "[#ffffff]Totals", x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.beaten_game
        Renderer.draw_font_ext(Assets.fnt_monogram, "[#ffffff]Beaten Game: " + (Save.beaten_game ? "[*]Yes" : "No"), x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.total_parries
        Renderer.draw_font(Assets.fnt_monogram, "Total Parries: " + Save.sum_parries.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.total_kills
        Renderer.draw_font(Assets.fnt_monogram, "Total Kills: " + Save.sum_kills.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.total_props_destroyed
        Renderer.draw_font(Assets.fnt_monogram, "Props Destroyed: " + Save.sum_props_destroyed.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.total_npcs_killed
        Renderer.draw_font(Assets.fnt_monogram, "NPCs Killed: " + Save.sum_npcs_killed.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.total_axes_thrown
        Renderer.draw_font(Assets.fnt_monogram, "Axes Thrown: " + Save.sum_axes_thrown.toString, x_stop, y_stop)
        y_stop = y_stop + advance
        //Save.total_runs
        Renderer.draw_font(Assets.fnt_monogram, "Total Runs: " + Save.total_runs.toString, x_stop, y_stop)
        y_stop = y_stop + advance        

        Renderer.target = null
    }

    pre_frame() {
        super.pre_frame()
        
        // Camera
        _ui_camera.x = 0
        _ui_camera.y = 0
        _ui_camera.width = Renderer.window_width
        _ui_camera.height = Renderer.window_height
        _ui_camera.w_on_screen = Renderer.window_width
        _ui_camera.h_on_screen = Renderer.window_height
        _ui_camera.update()
        _background_camera.x = 0
        _background_camera.y = 0
        _background_camera.width = Renderer.window_width / 4
        _background_camera.height = Renderer.window_height / 4
        _background_camera.w_on_screen = Renderer.window_width
        _background_camera.h_on_screen = Renderer.window_height
        _background_camera.update()
        CameraManager.update_backbuffer()
    }

    draw_digits(num, x, y) {
        var move_x = _ui_scale * 5 * 3
        Assets.spr_digits.scale_x = _ui_scale
        Assets.spr_digits.scale_y = _ui_scale
        for (character in num.toString) {
            var digit = Num.fromString(character)
            Renderer.draw_sprite(Assets.spr_digits, digit, x, y)
            x = x + move_x
        }
        Assets.spr_digits.scale_x = Save.ui_scale
        Assets.spr_digits.scale_y = Save.ui_scale
    }

    draw_digits(num, x, y, scale) {
        var move_x = scale * 5 * 3
        Assets.spr_digits.scale_x = scale
        Assets.spr_digits.scale_y = scale
        for (character in num.toString) {
            var digit = Num.fromString(character)
            Renderer.draw_sprite(Assets.spr_digits, digit, x, y)
            x = x + move_x
        }
        Assets.spr_digits.scale_x = Save.ui_scale
        Assets.spr_digits.scale_y = Save.ui_scale
    }

    draw_digits_wenrad(num, x, y) {
        var move_x = _ui_scale * 5 * 3
        Assets.spr_digits.scale_x = _ui_scale
        Assets.spr_digits.scale_y = _ui_scale
        for (character in num.toString) {
            var digit = Num.fromString(character)
            Renderer.draw_sprite(Assets.spr_digits, digit, x, y)
            x = x + move_x
        }
        Renderer.draw_sprite(Assets.spr_digits, 10, x, y)
        Assets.spr_digits.scale_x = Save.ui_scale
        Assets.spr_digits.scale_y = Save.ui_scale
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
        cx = _time * 2
        cy = _time * 1
        cwidth = _ui_camera.width
        cheight = _ui_camera.height
        var factor = 4
        var twidth = texture.width * factor
        var theight = texture.height * factor

        var tile_start_x = cx * parallax
        var tile_start_y = cy * parallax
        tile_start_x = (tile_start_x + (((cx - tile_start_x) / twidth).floor * twidth)) - twidth
        tile_start_y = (tile_start_y + (((cy - tile_start_y) / theight).floor * theight)) - theight
        var horizontal = (cwidth / twidth).ceil + 1
        var vertical = (cheight / theight).ceil + 1
        for (y in 0..vertical) {
            for (x in 0..horizontal) {
                Renderer.draw_texture(texture, tile_start_x + (x * twidth), tile_start_y + (y * theight), factor, factor, 0, 0, 0)
            }
        }
    }

    update() {
        CameraManager.begin_backbuffer()
        super.update()
        Renderer.lock_cameras(_ui_camera)
        Controls.update_menu()
        var add = Engine.delta
        if (Controls.menu_confirm) {
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
            _music = Audio.play(Assets.aud_title, true, Save.volume, Save.volume)
        }
        _titlecard_time = _titlecard_time + add

        if (Renderer.fullscreen) {
            _ui_scale = Save.ui_scale + 1
        } else {
            _ui_scale = Save.ui_scale
        }

        // Background
        draw_tiling_background(Assets.tex_background, 7)
        Renderer.colour_mod = [1, 1, 1, 0.15]
        draw_tiling_background(Assets.tex_cloudlayer, 9)
        Renderer.colour_mod = [1, 1, 1, 1]

        Renderer.lock_cameras(_background_camera)
        for (cloud in _clouds_background) {
            //cloud.draw(false)
        }
        Renderer.lock_cameras(_ui_camera)

        var middle_x = Renderer.window_width / 2
        var middle_y = Renderer.window_height / 2
        Renderer.draw_texture(Assets.tex_titlecard, middle_x - (Assets.tex_titlecard.width * _ui_scale * 0.5), (Renderer.window_height * 0.05) - (bounce(_titlecard_time) * _ui_scale * 100), _ui_scale, _ui_scale, 0, 0, 0)

        // Draws the menu buttons
        if (_titlecard_time > 2.348) {
            if (!ignore_frame) {
                _text_menu.update()
            }
            _text_menu.draw(middle_x, middle_y + (Renderer.window_height * 0.13 ), _ui_scale)
        }

        Renderer.lock_cameras(_background_camera)
        for (cloud in _clouds_foreground) {
            //cloud.draw(false)
        }
        Renderer.lock_cameras(_ui_camera)

        // Draw help
        if (_showing_help) {
            Renderer.draw_texture(Assets.tex_tutorial, 0, 0, Renderer.window_width / Assets.tex_tutorial.width, Renderer.window_height / Assets.tex_tutorial.height, 0, 0, 0)
        }
        if (_showing_stats) {
            var xx = (Renderer.window_width * 0.5) - (_stats_surface.width * 0.5 * _ui_scale)
            var yy = (Renderer.window_height * 0.7) - (_stats_surface.height * 0.5 * _ui_scale)
            Renderer.draw_texture(_stats_surface, xx, yy, _ui_scale, _ui_scale, 0, 0, 0)
        }

        // Draw the fade out
        if (_play) {
            Renderer.colour_mod = [0, 0, 0, 1]
            Renderer.draw_rectangle(0, 0, Renderer.window_width, Renderer.window_height - Renderer.window_height * bounce(Math.lerp((1 - (_fade_out / _fade_out_start)), 0, 2.6)), 0, 0, 0)
            Renderer.colour_mod = [1, 1, 1, 1]
            _fade_out = _fade_out - Engine.delta
            if (_fade_out <= 0) {
                Save.save()
                Audio.stop_all()
                Engine.switch_level(Between.new())
            }
        }
        CameraManager.end_backbuffer()

        // Fullscreen
        if (Keyboard.key(Keyboard.KEY_LALT) && Keyboard.key_pressed(Keyboard.KEY_RETURN)) {
            Renderer.fullscreen = !Renderer.fullscreen
            Save.fullscreen = Renderer.fullscreen
            _background_camera.width = Renderer.window_width / 4
            _background_camera.height = Renderer.window_height / 4
            _background_camera.w_on_screen = Renderer.window_width
            _background_camera.h_on_screen = Renderer.window_height
            reset_clouds()
        }
        _time = _time + Engine.delta
    }

    destroy() {
        Save.save()
        super.destroy()
    }
}