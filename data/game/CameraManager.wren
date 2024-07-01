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
    }

    ui_camera { _ui_camera }
    game_camera { _game_camera }
    parallax_camera { _parallax_camera }
    perspective_camera { _perspective_camera }
    menu_camera { _menu_camera }
    menu_background_camera { _menu_background_camera }
    transistion_camera { _transistion_camera }
}

var CameraManager = CameraManagerImpl.new()