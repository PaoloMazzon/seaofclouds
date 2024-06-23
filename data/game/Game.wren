import "Constants" for Constants
import "Player" for Player
import "random" for Random
import "Generator" for Generator
import "Save" for Save

class Cloud {
    construct new(rng, width, height) {
        _frame = rng.int(Assets.spr_clouds.frame_count)
        _speed = rng.float(4, 10)
        _x = rng.float(-Assets.spr_clouds.width, width - Assets.spr_clouds.width)
        _y = rng.float(-Assets.spr_clouds.height, height - Assets.spr_clouds.height)
        _room_width = width
        _room_height = height
    }

    draw(is_paused) {
        if (!is_paused) {
            _x = _x + (_speed * Engine.delta)
            if (_x > _room_width) {
                _x = -Assets.spr_clouds.width
            }
        }

        Renderer.draw_sprite(Assets.spr_clouds, _frame, _x, _y)
    }
}

// Handles an individual skill check by triggering a fiber
class SkillCheck {
    static SKILL_CHECK_EASY { 1 }
    static SKILL_CHECK_HARD { 3 }

    construct new(difficulty, fiber, rng) {
        _difficulty = difficulty
        _fiber = fiber
        _fade_in_timer = Constants.SKILL_CHECK_FADE_IN_TIME
        _pointer_position = rng.float(Num.tau)
        _goal_position = _pointer_position + rng.float(Num.pi, Num.tau)
        _difficulty_texture = difficulty == SkillCheck.SKILL_CHECK_EASY ? Assets.tex_skillcheckeasy : Assets.tex_skillcheckhard
        _difficulty_tolerance = difficulty == SkillCheck.SKILL_CHECK_EASY ? 0.386133 : 0.207036
        Audio.play(Assets.aud_skillcheck, false, Save.volume, Save.volume)
    }

    update(camera) {
        var skill_check_done = false
        _fade_in_timer = _fade_in_timer - Engine.delta

        // Perform the skill check
        if (_fade_in_timer <= 0) {
            _pointer_position = _pointer_position + (Constants.SKILL_CHECK_SPEED * Engine.delta)

            // If the player attempts
            if (Keyboard.key_pressed(Keyboard.KEY_SPACE)) {
                skill_check_done = true
                if (_pointer_position >= _goal_position - _difficulty_tolerance && _pointer_position <= _goal_position + _difficulty_tolerance) {
                    _fiber.call(true)
                    Audio.play(Assets.aud_passedskillcheck, false, Save.volume, Save.volume)
                } else {
                    _fiber.call(false)
                    Audio.play(Assets.aud_failedskillcheck, false, Save.volume, Save.volume)
                }
            }

            // If the attempt passes
            if (_pointer_position > _goal_position + _difficulty_tolerance && !skill_check_done) {
                skill_check_done = true
                _fiber.call(false)
                Audio.play(Assets.aud_failedskillcheck, false, Save.volume, Save.volume)
            }
        }

        // Draw skill check
        var centerX = camera.width / 2
        var centerY = camera.height / 2
        var drawX = centerX - (Assets.tex_skillcheckcircle.width / 2)
        var drawY = centerY - (Assets.tex_skillcheckcircle.height / 2)
        Renderer.lock_cameras(camera)
        Renderer.draw_texture(Assets.tex_skillcheckcircle, drawX, drawY)
        Renderer.draw_texture(_difficulty_texture, drawX, drawY, 1, 1, _goal_position, Assets.tex_skillcheckcircle.width / 2, Assets.tex_skillcheckcircle.height / 2)
        Renderer.draw_texture(Assets.tex_skillcheckpointer, drawX, drawY, 1, 1, _pointer_position, Assets.tex_skillcheckcircle.width / 2, Assets.tex_skillcheckcircle.height / 2)

        return skill_check_done
    }
}

class Game is Level {
    construct new() {
        _start_time = 0
        _title_length = 0
        _stop_time = 0
        _screen_shake = 0
        _skill_check = null
        _clouds_foreground = []
        _clouds_background = []
        _focal_x = 0
        _focal_y = 0
        _focal_zoom = 1
        _paused = false
        _fade_in = Constants.FADE_TIME
        _fade_out = 0
    }
    rng { _rng }

    // Triggers a skillcheck - fiber is called with the result, true for passed
    skill_check(difficulty, fiber) {
        _skill_check = SkillCheck.new(difficulty, fiber, _rng)
    }

    // Handles internal things like screen shake and pausing
    process_meta() {
        if (!is_paused) {
            _screen_shake = _screen_shake - Engine.delta
        }
        _stop_time = _stop_time - Engine.delta
    }

    // Pauses game for a given period of time in seconds
    pause(time) {
        _stop_time = time
    }

    // Pauses indefinetely
    pause() {
        _paused = true
    }

    // Unpauses
    unpause() {
        _paused = false
        _stop_time = 0
    }

    // Toggles the pause
    toggle_pause() {
        _paused = !_paused
    }

    // Shakes the screen for a given amount of time in seconds
    shake_screen(time) {
        _screen_shake = time
    }

    // Returns true if a skill check is currently happening
    in_skill_check { _skill_check != null }

    // Returns true if the game is paused for any reason
    is_paused { _stop_time > 0 || _paused || _skill_check != null || _fade_in > 0 || _fade_out > 0 }

    // Returns true if the screen is shaking
    is_shaking {
        return _screen_shake > 0 && !is_paused
    }

    // Ground tileset
    tileset { _tileset }

    set_focal_point(x, y, zoom) {
        _focal_x = x
        _focal_y = y
        _focal_zoom = zoom
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
        Renderer.use_cameras_on_surfaces = false
        _tileset_surface = _tileset.draw_to_surface()
        _background_tileset_surface = _background_tileset.draw_to_surface()
        _foreground_tileset_surface = _foreground_tileset.draw_to_surface()
        
        // Clouds
        for (i in 1..(Constants.CLOUD_COUNT / 2)) {
            _clouds_background.add(Cloud.new(_rng, _tileset_surface.width, _tileset_surface.height))
            _clouds_foreground.add(Cloud.new(_rng, _tileset_surface.width, _tileset_surface.height))
        }

        // Create player
        _player = add_entity(Player)
        _player.x = _gen.player_start_x
        _player.y = _gen.player_start_y

        // Setup cameras
        _game_camera = Camera.new()
        _ui_camera = Camera.new()
        var aspectRatio = Renderer.window_width / Renderer.window_height
        _game_camera.width = Constants.GAME_HEIGHT * aspectRatio
        _game_camera.height = Constants.GAME_HEIGHT
        _game_camera.x = _player.x - (_game_camera.width / 2)
        _game_camera.y = _player.y - (_game_camera.height / 2)
        set_focal_point(_player.x, _player.y, 1)
        _window_surface = Surface.new(Renderer.window_width, Renderer.window_height)
    }

    pre_frame() {
        super.pre_frame()

        if (!is_paused) {
            // Calculate camera's width and height
            var aspectRatio = Renderer.window_width / Renderer.window_height
            _game_camera.width = (Constants.GAME_HEIGHT * aspectRatio) / _focal_zoom 
            _game_camera.height = Constants.GAME_HEIGHT / _focal_zoom
            _game_camera.w_on_screen = Renderer.window_width
            _game_camera.h_on_screen = Renderer.window_height
            _game_camera.x = _game_camera.x + 0.05 * ((_focal_x - (_game_camera.width / 2)) - _game_camera.x)
            _game_camera.y = _game_camera.y + 0.05 * ((_focal_y - (_game_camera.height / 2)) - _game_camera.y)

            if (is_shaking) {
                _game_camera.x = _game_camera.x + _rng.float(-Constants.SHAKE_INTENSITY, Constants.SHAKE_INTENSITY)
                _game_camera.y = _game_camera.y + _rng.float(-Constants.SHAKE_INTENSITY, Constants.SHAKE_INTENSITY)
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

        _ui_camera.width = Renderer.window_width
        _ui_camera.height = Renderer.window_height
        _ui_camera.w_on_screen = Renderer.window_width
        _ui_camera.h_on_screen = Renderer.window_height

        _ui_camera.update()
        _game_camera.update()

        // Update window surface if resized
        if (_window_surface.width != Renderer.window_width || _window_surface.height != Renderer.window_height) {
            _window_surface = Surface.new(Renderer.window_width, Renderer.window_height)
        }
    }

    update() {
        Renderer.lock_cameras(_game_camera)

        // Background and tiles
        Renderer.colour_mod = Constants.SKY_COLOUR
        Renderer.clear()
        Renderer.colour_mod = [1, 1, 1, 1]
        for (cloud in _clouds_background) {
            cloud.draw(is_paused)
        }
        Renderer.draw_texture(_background_tileset_surface, 0, 0)
        Renderer.draw_texture(_tileset_surface, 0, 0)
        Renderer.draw_texture(_foreground_tileset_surface, 0, 0)

        // Entities
        super.update()
        for (cloud in _clouds_foreground) {
            cloud.draw(is_paused)
        }

        // Top-level game stuff
        process_meta()
        if (_skill_check != null) {
            if (_skill_check.update(_ui_camera)){ 
                _skill_check = null
            }
        }

        // Fade in and out
        if (_fade_in > 0 || _fade_out > 0) {
            var percent = 0
            if (_fade_in > 0) {
                percent = 1 - (_fade_in / Constants.FADE_TIME)
                _fade_in = _fade_in - Engine.delta
            } else {
                percent = _fade_out / Constants.FADE_TIME
                _fade_out = _fade_out - Engine.delta
            }
            
            Renderer.target = _window_surface
            Renderer.colour_mod = [0, 0, 0, 1]
            Renderer.clear()
            Renderer.blend_mode = Renderer.BLEND_MODE_SUBTRACT
            Renderer.draw_circle(_window_surface.width / 2, _window_surface.height / 2, ((_window_surface.width / 2) * 1.2) * percent)
            Renderer.blend_mode = Renderer.BLEND_MODE_BLEND
            Renderer.target = Renderer.RENDER_TARGET_DEFAULT
            Renderer.lock_cameras(_ui_camera)
            Renderer.draw_texture(_window_surface, 0, 0)
        }

        // Debug
        if (Keyboard.key_pressed(Keyboard.KEY_Y)) {
            shake_screen(0.1)
        }
        if (Keyboard.key_pressed(Keyboard.KEY_U)) {
            pause(0.5)
        }
        if (Keyboard.key_pressed(Keyboard.KEY_E)) {
            var f = Fiber.new { |success|
                System.print(success)
            }
            skill_check(SkillCheck.SKILL_CHECK_EASY, f)
        }
        if (Keyboard.key_pressed(Keyboard.KEY_H)) {
            var f = Fiber.new { |success|
                System.print(success)
            }
            skill_check(SkillCheck.SKILL_CHECK_HARD, f)
        }

        // Fullscreen
        if (Keyboard.key(Keyboard.KEY_LALT) && Keyboard.key_pressed(Keyboard.KEY_RETURN)) {
            Renderer.fullscreen = !Renderer.fullscreen
        }
    }

    destroy() {
        super.destroy()
    }
}