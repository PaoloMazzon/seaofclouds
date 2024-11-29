import "Save" for Save

class CameraManagerImpl {
    construct new() {
        _has_setup = false
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
        _crt_shader = Shader.load("data/shaders/crt.vert.spv", "data/shaders/crt.frag.spv", 0)
        _post_fx_surface = Surface.new(Renderer.window_width, Renderer.window_height)
    }

    update_backbuffer() {
        if (_post_fx_surface.width != Renderer.window_width || _post_fx_surface.height != Renderer.window_height) {
            _post_fx_surface.free()
            _post_fx_surface = Surface.new(Renderer.window_width, Renderer.window_height)
        }
    }

    begin_backbuffer() {
        Renderer.use_cameras_on_surfaces = true
        Renderer.target = _post_fx_surface
        Renderer.clear()
    }

    end_backbuffer() {
        Renderer.target = Renderer.RENDER_TARGET_DEFAULT
        Renderer.use_cameras_on_surfaces = false
        Renderer.shader = crt_shader
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