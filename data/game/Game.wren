import "Constants" for Constants
import "Player" for Player
import "random" for Random
import "Generator" for Generator

class Game is Level {
    construct new() {
        _start_time = 0
        _title_length = 0
        _stop_frames = 0
        _screen_shake = 0
    }
    rng { _rng }

    // Handles internal things like screen shake and pausing
    process_meta() {
        if (!is_paused) {
            _screen_shake = _screen_shake - 1
        }
        _stop_frames = _stop_frames - 1
    }

    pause(frames) {
        _stop_frames = frames
    }

    shake_screen(frames) {
        _screen_shake = frames
    }

    is_paused {
        _stop_frames > 0
    }

    is_shaking {
        _screen_shake > 0 && !is_paused
    }

    create() {
        super.create()
        _rng = Random.new()

        // Generate level
        _gen = Generator.new()
        _gen.tile_width = 24
        _gen.tile_height = 16
        _gen.tileset_tex = Assets.tex_tiles
        _gen.island_radius_max = 9
        _gen.island_radius_min = 4
        _gen.minimum_distance = _gen.island_radius_max * 1.5
        var tilesets = _gen.generate_level(100, 100, 12, _rng.int())
        _tileset = tilesets["ground"]
        _background_tileset = tilesets["background"]
        _foreground_tileset = tilesets["foreground"]

        // Tileset surface
        _tileset_surface = _tileset.draw_to_surface()
        _background_tileset_surface = _background_tileset.draw_to_surface()
        _foreground_tileset_surface = _foreground_tileset.draw_to_surface()

        // Create player
        _player = add_entity(Player)
        _player.x = _gen.player_start_x
        _player.y = _gen.player_start_y

        // Setup cameras
        _game_camera = Camera.new()
        var aspectRatio = Renderer.window_width / Renderer.window_height
        _game_camera.width = Constants.GAME_HEIGHT * aspectRatio
        _game_camera.height = Constants.GAME_HEIGHT
        _game_camera.x = _player.x - (_game_camera.width / 2)
        _game_camera.y = _player.y - (_game_camera.height / 2)
    }

    pre_frame() {
        super.pre_frame()

        if (!is_paused) {
            // Calculate camera's width and height
            var aspectRatio = Renderer.window_width / Renderer.window_height
            _game_camera.width = Constants.GAME_HEIGHT * aspectRatio
            _game_camera.x = _game_camera.x + 0.05 * ((_player.x - (_game_camera.width / 2)) - _game_camera.x)
            _game_camera.y = _game_camera.y + 0.05 * ((_player.y - (_game_camera.height / 2)) - _game_camera.y)

            if (is_shaking) {
                _game_camera.x = _game_camera.x + _rng.int(-2, 2)
                _game_camera.y = _game_camera.y + _rng.int(-2, 2)
            }
        }

        // Debug
        if (Keyboard.key(Keyboard.KEY_P)) {
            _game_camera.x = 0
            _game_camera.y = 0
            _game_camera.width = _tileset_surface.width
            _game_camera.height = _tileset_surface.height
            _game_camera.w_on_screen = Renderer.window_width
            _game_camera.h_on_screen = Renderer.window_height
        } else if (Keyboard.key_released(Keyboard.KEY_P)) {
            var aspectRatio = Renderer.window_width / Renderer.window_height
            _game_camera.width = Constants.GAME_HEIGHT * aspectRatio
            _game_camera.height = Constants.GAME_HEIGHT
            _game_camera.x = _player.x - (_game_camera.width / 2)
            _game_camera.y = _player.y - (_game_camera.height / 2)
        } 

        _game_camera.update()
    }

    update() {
        Renderer.lock_cameras(_game_camera)

        // Background and tiles
        Renderer.colour_mod = Constants.SKY_COLOUR
        Renderer.clear()
        Renderer.colour_mod = [1, 1, 1, 1]
        Renderer.draw_texture(_background_tileset_surface, 0, 0)
        Renderer.draw_texture(_tileset_surface, 0, 0)
        Renderer.draw_texture(_foreground_tileset_surface, 0, 0)

        // Entities
        if (!is_paused) {
            super.update()
        }

        process_meta()
    }

    destroy() {
        super.destroy()
    }
}