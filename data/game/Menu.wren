import "random" for Random
import "Save" for Save
import "Constants" for Constants
import "Game" for Game, Cloud
import "Controls" for Controls

class Menu is Level {
    // Menus
    MENU_MAIN { 0 }
    MENU_SETTINGS { 1 }
    MENU_STATS { 2 }

    // Cursor positions
    MENU_MAIN_PLAY { 0 }
    MENU_MAIN_SETTINGS { 1 }
    MENU_MAIN_STATS { 2 }
    MENU_MAIN_QUIT { 3 }

    MENU_SETTINGS_FULLSCREEN { 0 }
    MENU_SETTINGS_VOLUME { 1 }
    MENU_SETTINGS_UI_SCALE { 2 }
    MENU_SETTINGS_SHAKE_INTENSITY { 3 }
    MENU_SETTINGS_BACK { 4 }

    MNUE_STATS_BACK { 0 }

    construct new() {
        _rng = Random.new(70)
        _clouds_foreground = []
        _clouds_background = []
        _titlecard_time = 0
        _cursor_pos = 0
        _menu = 0
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
        _background_camera = Camera.new()
        _ui_camera = Camera.new()
        _background_camera.width = Renderer.window_width / 2
        _background_camera.height = Renderer.window_height / 2
        _background_camera.w_on_screen = Renderer.window_width
        _background_camera.h_on_screen = Renderer.window_height
        _background_camera.update()
        reset_clouds()
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
        return time >= 2.667 * 3 ? 0 : (0.2 * ((time - 8) * (time - 8).sin).abs)
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

    process_menu() {
        var texture = _menu == MENU_MAIN ? Assets.tex_mainmenu : Assets.tex_settings

        if (_menu == MENU_MAIN) {
            if (Controls.menu_down) {
                _cursor = (_cursor + 1) % (MENU_MAIN_QUIT + 1)
            } else if  (Controls.menu_down) {
                _cursor = _cursor == 0 ? MENU_MAIN_QUIT : _cursor - 1
            }

        } else if (_menu == MENU_SETTINGS) {
            if (Controls.menu_down) {
                _cursor = (_cursor + 1) % (MENU_SETTINGS_BACK + 1)
            } else if  (Controls.menu_down) {
                _cursor = _cursor == 0 ? MENU_SETTINGS_BACK : _cursor - 1
            }
        } else if (_menu == MENU_STATS) {
            if (Controls.confirm) {
                _menu = MENU_MAIN
                _cursor = 0
            }
            // TODO: Draw stats
        }
    }

    update() {
        super.update()
        Renderer.lock_cameras(_ui_camera)
        var add = Engine.delta
        if (Controls.confirm) {
            add = 2.667
        }
        if (add + _titlecard_time > 2.667 && _titlecard_time < 2.667) {
            // The moment the title card is done
        }
        _titlecard_time = _titlecard_time + add

        // Background
        draw_tiling_background(Assets.tex_background, 8)

        Renderer.lock_cameras(_background_camera)
        for (cloud in _clouds_background) {
            cloud.draw(false)
        }
        Renderer.lock_cameras(_ui_camera)

        var middle_x = Renderer.window_width / 2
        var middle_y = Renderer.window_height / 2
        Renderer.draw_texture(Assets.tex_titlecard, middle_x - (Assets.tex_titlecard.width * Save.ui_scale * 0.5), (Renderer.window_height * 0.05) - (bounce(_titlecard_time) * Save.ui_scale * 100), Save.ui_scale, Save.ui_scale, 0, 0, 0)

        // Draws the menu buttons
        if (_titlecard_time > 2.667) {
            process_menu()
        }

        Renderer.lock_cameras(_background_camera)
        for (cloud in _clouds_foreground) {
            cloud.draw(false)
        }
        Renderer.lock_cameras(_ui_camera)

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
        super.destroy()
    }
}