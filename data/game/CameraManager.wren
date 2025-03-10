import "Save" for Save
import "TextMenu" for TextMenu, MenuOption

class CameraManagerImpl {
    construct new() {
        _has_setup = false
        _text_menu = null
        _unpause = false
        _quit_to_menu = false
        _music_is_updated = false
    }

    setup() {
        if (_has_setup) {
            return
        }
        _has_setup = true

        _ui_camera = Camera.new()
        _game_camera = Camera.new()
        _parallax_camera = Camera.new()
        _perspective_camera = Camera.new()
        _menu_camera = Camera.new()
        _menu_background_camera = Camera.new()
        _transistion_camera = Camera.new()
        _character_shader = Shader.load("data/shaders/outline.vert.spv", "data/shaders/outline.frag.spv", 0)
        _crt_shader = Shader.load("data/shaders/crt.vert.spv", "data/shaders/crt.frag.spv", 8)
        _crt_shader_buffer = Buffer.new(8)
        _post_fx_surface = Surface.new(Renderer.window_width, Renderer.window_height)

        // Setup the pause menu
        _text_menu = TextMenu.new()
        var top = _text_menu.top_menu
        var options = _text_menu.add_menu("options")
        var quit = _text_menu.add_menu("quit")

        // Top level
        var play_fn = Fn.new {
            _unpause = true
        }
        var options_fn = Fn.new {
            _text_menu.set_menu("options")
        }
        var quit_fn = Fn.new {
            _text_menu.set_menu("quit")
        }
        top.add_option(MenuOption.new("Play", play_fn, MenuOption.TYPE_NONE))
        top.add_option(MenuOption.new("Options", options_fn, MenuOption.TYPE_NONE))
        top.add_option(MenuOption.new("Quit", quit_fn, MenuOption.TYPE_NONE))

        // Options
        var volume_fn = Fn.new { |volume| 
            Save.volume = volume
            _music_is_updated = true
        }
        var fullscreen_fn = Fn.new {
            Renderer.fullscreen = !Renderer.fullscreen
            Save.fullscreen = Renderer.fullscreen
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
        var back_to_menu_fn = Fn.new {
            _text_menu.set_menu("top")
        }
        options.add_option(MenuOption.new("Volume", volume_fn, MenuOption.TYPE_SLIDER, Save.volume))
        options.add_option(MenuOption.new("Fullscreen", fullscreen_fn, MenuOption.TYPE_NONE))
        options.add_option(MenuOption.new("Screen Shake", shake_intensity_fn, MenuOption.TYPE_SLIDER, Save.shake_modifier))
        options.add_option(MenuOption.new("UI Scale", ui_scale_fn, MenuOption.TYPE_NONE))
        options.add_option(MenuOption.new("CRT Shader", crt_filter_fn, MenuOption.TYPE_RADIO, Save.crt_effect))
        options.add_option(MenuOption.new("Back", back_to_menu_fn, MenuOption.TYPE_NONE))
        options.x_offset = -26

        // Quit menu
        var quit_to_menu_fn = Fn.new {
            _quit_to_menu = true
        }
        quit.add_option(MenuOption.new("Nevermind", back_to_menu_fn, MenuOption.TYPE_NONE))
        quit.add_option(MenuOption.new("Quit (prob)", quit_to_menu_fn, MenuOption.TYPE_NONE))

        // The draw parameters for the menu
        _text_menu.x_offset = 4
        _text_menu.y_offset = -2
        _text_menu.align_x = TextMenu.ALIGN_CENTER
        _text_menu.align_y = TextMenu.ALIGN_CENTER
        _text_menu.finalize()
    }

    text_menu { _text_menu }
    unpause { _unpause }
    unpause=(s) { _unpause = s }
    quit_to_menu {
        if (_quit_to_menu) {
            _quit_to_menu = false
            return true
        }
        return false
    }
    music_is_updated {
        if (_music_is_updated) {
            _music_is_updated = false
            return true
        }
        return false
    }

    update_backbuffer() {
        if (_post_fx_surface.width != Renderer.window_width || _post_fx_surface.height != Renderer.window_height) {
            _post_fx_surface.free()
            _post_fx_surface = Surface.new(Renderer.window_width, Renderer.window_height)
        }
    }

    backbuffer { _post_fx_surface }

    begin_backbuffer() {
        Renderer.use_cameras_on_surfaces = true
        Renderer.target = _post_fx_surface
        Renderer.clear()
    }

    end_backbuffer() {
        _crt_shader_buffer = Buffer.new(8) // this is a shit solution
        _crt_shader_buffer.write_float(_post_fx_surface.width)
        _crt_shader_buffer.write_float(_post_fx_surface.height)
        Renderer.target = Renderer.RENDER_TARGET_DEFAULT
        Renderer.use_cameras_on_surfaces = false
        Renderer.shader = crt_shader
        if (crt_shader != null) {
            crt_shader.data = _crt_shader_buffer
        }
        Renderer.draw_texture(_post_fx_surface, 0, 0)
        Renderer.shader = null
    }

    ui_camera { _ui_camera }
    game_camera { _game_camera }
    parallax_camera { _parallax_camera }
    perspective_camera { _perspective_camera }
    menu_camera { _menu_camera }
    menu_background_camera { _menu_background_camera }
    transistion_camera { _transistion_camera }
    character_shader { _character_shader }
    crt_shader {
        if (Save.crt_effect) {
            return _crt_shader
        }
        return null
    }
}

var CameraManager = CameraManagerImpl.new()