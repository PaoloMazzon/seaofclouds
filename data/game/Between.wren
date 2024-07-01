import "Controls" for Controls
import "Constants" for Constants
import "Save" for Save
import "random" for Random
import "CameraManager" for CameraManager

class Between is Level {
    construct new() {  }

    create() {
        super.create()
        _time = 0
        _time_limit = 8
        _rng = Random.new()
        _upside_down = _rng.int(50) == 5

        // 2d camera
        _game_camera = CameraManager.transistion_camera
        var aspectRatio = Renderer.window_width / Renderer.window_height
        _game_camera.width = Constants.GAME_HEIGHT * aspectRatio
        _game_camera.height = Constants.GAME_HEIGHT
        _game_camera.update()

        // Load 3d stuff
        _3d_camera = CameraManager.perspective_camera
        _3d_camera.w_on_screen = Renderer.window_width
        _3d_camera.h_on_screen = Renderer.window_height
        _3d_camera.width = Renderer.window_width
        _3d_camera.height = Renderer.window_height
        _3d_camera.eyes = [4, 1, 4]
        _3d_camera.centre = [0, 0, 0]
        _3d_camera.up = [0, 1, 0]
        _3d_camera.fov = 90 * (Num.pi / 180)
        _3d_camera.type = Camera.CAMERA_TYPE_PERSPECTIVE
        _3d_camera.update()
        _model = Model.load("data/player_model.obj", Assets.tex_player_model)

        // Teleport effect
        _lines = []
        for (i in 0..100) {
            _lines.add([_rng.float(-50, 50), _rng.float(Constants.GAME_HEIGHT), _rng.float(30, 50)])
        }

        // Music
        _music = Audio.play(Assets.aud_teleportmusic, false, 0, 0)
    }

    pre_frame() {
        super.pre_frame()

        var aspectRatio = Renderer.window_width / Renderer.window_height
        _game_camera.x = 0
        _game_camera.y = 0
        _game_camera.width = Constants.GAME_HEIGHT * aspectRatio
        _game_camera.height = Constants.GAME_HEIGHT
        _game_camera.w_on_screen = Renderer.window_width
        _game_camera.h_on_screen = Renderer.window_height
        _3d_camera.width = Renderer.window_width
        _3d_camera.height = Renderer.window_height
        _3d_camera.w_on_screen = Renderer.window_width
        _3d_camera.h_on_screen = Renderer.window_height
        _game_camera.update()
        _3d_camera.update()
    }

    exp(percent, start, stop) {
        var p = -((percent - 1).pow(2)) + 1
        return start + (p * (stop - start))
    }

    update() {
        super.update()
        _time = _time + Engine.delta
        Renderer.lock_cameras(_game_camera)
        Renderer.colour_mod = Constants.SKY_COLOUR
        Renderer.clear()
        Renderer.colour_mod = [1, 1, 1, 1]

        // Draw background
        Renderer.lock_cameras(_game_camera)
        if (Save.stage <= 3) {
            var bg = Assets.tex_background
            if (Save.stage == 2) {
                bg = Assets.tex_backgroundfar
            } else if (Save.stage == 3) {
                bg = Assets.tex_backgroundfarther
            }
            Tileset.draw_tiling_background(bg, 0.95, _game_camera)
        } else {
            Tileset.draw_tiling_background(Assets.tex_backgroundspace, 0.98, _game_camera)
            Tileset.draw_tiling_background(Assets.tex_backgroundstars, 0.95, _game_camera)
            Tileset.draw_tiling_background(Assets.tex_backgroundstars2, 0.925, _game_camera)
            Renderer.draw_texture(Assets.tex_planet, 0, _game_camera.height - Assets.tex_planet.height)
        }
        for (line in _lines) {
            line[1] = line[1] - (line[2] * Engine.delta)
            if (line[1] < 0) {
                line[1] = Constants.GAME_HEIGHT + 5
            }
            Renderer.draw_line(line[0] + (_game_camera.width / 2), line[1], line[0] + (_game_camera.width / 2), line[1] - 5)
        }

        // Draw player model
        Renderer.lock_cameras(_3d_camera)
        Renderer.draw_model(_model, 0, Math.serp(_time / _time_limit, -10, 10), 0, 1, _upside_down ? -1 : 1, 1, _time * 5, [0, 1, 0], 0, 0, 0)

        // Draw fade in/out
        Renderer.lock_cameras(_game_camera)
        if (_time < Constants.FADE_TIME) {
            var percent = 1 - (_time / Constants.FADE_TIME)
            _music.update(false, (1 - percent) * Save.volume, (1 - percent) * Save.volume)
            var x_pos = exp(1 - percent, -(Assets.tex_ascending.width / 2), (_game_camera.width / 2) - (Assets.tex_ascending.width / 2))
            Renderer.draw_texture(Assets.tex_ascending, x_pos, (_game_camera.height / 2) - (Assets.tex_ascending.height / 2))

            Renderer.colour_mod = [0, 0, 0, percent]
            Renderer.draw_rectangle(0, 0, _game_camera.width, _game_camera.height, 0, 0, 0)
        } else if (_time > _time_limit - Constants.FADE_TIME) {
            var percent = 1 - ((_time_limit - _time) / Constants.FADE_TIME)
            _music.update(false, (1 - percent) * Save.volume, (1 - percent) * Save.volume)
            var x_pos = exp(1 - percent, (_game_camera.width), (_game_camera.width / 2) - (Assets.tex_ascending.width / 2))
            Renderer.draw_texture(Assets.tex_ascending, x_pos, (_game_camera.height / 2) - (Assets.tex_ascending.height / 2))

            Renderer.colour_mod = [0, 0, 0, percent]
            Renderer.draw_rectangle(0, 0, _game_camera.width, _game_camera.height, 0, 0, 0)
        } else {
            Renderer.draw_texture(Assets.tex_ascending, (_game_camera.width / 2) - (Assets.tex_ascending.width / 2), (_game_camera.height / 2) - (Assets.tex_ascending.height / 2))
        }
        Renderer.colour_mod = [1, 1, 1, 1]
        
        // Move to next level
        if (Controls.confirm || _time > _time_limit) {
            Audio.stop_all()
            var game = Engine.get_class("Game::Game")
            Engine.switch_level(game.new())
        }
    }
}