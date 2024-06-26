import "Constants" for Constants
import "Player" for Player
import "random" for Random
import "Generator" for Generator
import "Save" for Save
import "Controls" for Controls
import "Attack" for Attack

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
            if (Controls.skill_check) {
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
        var spr_controls = Controls.on_gamepad ? Assets.spr_gamepadcontrols : Assets.spr_keyboardcontrols
        Renderer.lock_cameras(camera)
        Renderer.draw_texture(Assets.tex_skillcheckcircle, drawX, drawY)
        Renderer.draw_texture(_difficulty_texture, drawX, drawY, 1, 1, _goal_position, Assets.tex_skillcheckcircle.width / 2, Assets.tex_skillcheckcircle.height / 2)
        Renderer.draw_texture(Assets.tex_skillcheckpointer, drawX, drawY, 1, 1, _pointer_position, Assets.tex_skillcheckcircle.width / 2, Assets.tex_skillcheckcircle.height / 2)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_CONFIRM, centerX - (spr_controls.width * Save.ui_scale * 0.5), centerY - (spr_controls.height * Save.ui_scale * 0.5))

        return skill_check_done
    }
}

class Particle {
    construct new(texture, x, y, direction, spread, speed, lifespan, spinspeed, rng) {
        _texture = texture
        _direction = direction + rng.float(-spread, spread)
        _speed = speed + rng.float(-speed * 0.1, speed * 0.1)
        _lifespan = lifespan
        _total_lifespan = lifespan
        _x = x
        _y = y
        _rotation = 0
        _spinspeed = spinspeed
    }

    // Returns true if time to go
    update() {
        _lifespan = _lifespan - Engine.delta
        var percent = _lifespan / _total_lifespan
        
        _x = _x + (_direction.cos * _speed * Engine.delta * percent)
        _y = _y + (_direction.sin * _speed * Engine.delta * percent)
        _rotation = _rotation + (_spinspeed * Engine.delta)

        var tw = _texture.width / 2
        var th = _texture.height / 2
        Renderer.colour_mod = [1, 1, 1, percent]
        Renderer.draw_texture(_texture, _x - tw, _y - th, 1, 1, _rotation, tw, th)
        Renderer.colour_mod = [1, 1, 1, 1]
        
        return _lifespan <= 0
    }
}

class Prop {
    construct new(x, y, rng) {
        _sprite = Assets.spr_props
        _sprite.origin_x = _sprite.width / 2
        _sprite.origin_y = _sprite.height / 2
        _frame = rng.sample([0, 1, 2, 3, 7, 4, 4, 4, 5, 5, 5, 6, 6, 6])
        var list = [
            Assets.tex_boxparticle,
            Assets.tex_vaseparticle, 
            Assets.tex_statueparticle, 
            Assets.tex_chairparticle, 
            Assets.tex_plantparticle, 
            Assets.tex_plantparticle, 
            Assets.tex_plantparticle, 
            Assets.tex_rockparticle
        ]
        _particle = list[_frame]
        _x = x
        _y = y
        _rng = rng
    }

    // Returns true if time to go
    update(level) {
        for (attack in level.get_entities(Attack)) {
            if (Math.point_distance(attack.x, attack.y, _x, _y) < attack.hitbox.w) {
                level.add_particles(_particle, _x, _y, Math.point_angle(attack.x, attack.y, _x, _y), Num.pi * 0.3, 50, 1, Num.pi, 8)
                if (_frame == 4 || _frame == 5 || _frame == 6) {
                    Audio.play(Assets.aud_plantcut, false, Save.volume, Save.volume)
                } else {
                    Audio.play(Assets.aud_cratebreak, false, Save.volume, Save.volume)
                }
                return true
            }
        }
        
        Renderer.draw_sprite(_sprite, _frame, _x, _y)
        return false
    }
}

class Game is Level {
    construct new() {
        _start_time = 0
        _title_length = 0
        _stop_time = 0
        _screen_shake = 0
        _shake_intensity_modifier = 1
        _skill_check = null
        _clouds_foreground = []
        _clouds_background = []
        _focal_x = 0
        _focal_y = 0
        _focal_zoom = 1
        _paused = false
        _fade_in = Constants.FADE_TIME
        _fade_out = 0
        _new_focal = null
        _particles = []
        _props = []
        _stage = 1
    }
    rng { _rng }
    player { _player }

    // Adds a new prop
    add_prop(x, y) {
        _props.add(Prop.new(x, y, _rng))
    }

    // Draws a parallax background
    draw_tiling_background(texture, parallax) {
        var cx = 0
        var cy = 0
        var cwidth = 0
        var cheight = 0
        cx = _parallax_camera.x
        cy = _parallax_camera.y
        cwidth = _parallax_camera.width
        cheight = _parallax_camera.height

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

    // Sets the new focal point for when the player dies
    set_replacement_focal(entity) {
        _new_focal = entity
    }

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

        // Find a new focal point if the player is dead
        if (player.is_dead && _new_focal != null) {
            set_focal_point(_new_focal.x, _new_focal.y, 1.2)
        }
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

    // Adds particles to the level
    add_particles(texture, x, y, direction, spread, speed, lifespan, spinspeed, count) {
        for (i in 0..count - 1) {
            _particles.add(Particle.new(texture, x, y, direction, spread, speed, lifespan, spinspeed, _rng))
        }
    }

    // Toggles the pause
    toggle_pause() {
        _paused = !_paused
    }

    // Shakes the screen for a given amount of time in seconds
    shake_screen(time) {
        _screen_shake = time
        _shake_intensity_modifier = 1
    }

    shake_screen(time, intensity_modifier) {
        _screen_shake = time
        _shake_intensity_modifier = intensity_modifier
    }

    // Returns true if a skill check is currently happening
    in_skill_check { _skill_check != null }

    // Returns true if the game is paused for any reason
    is_paused { _stop_time > 0 || _paused || _skill_check != null || _fade_in > 0 || _fade_out > 0 }

    // Returns true if the screen is shaking
    is_shaking {
        return _screen_shake > 0 && !is_paused
    }

    stage { _stage }

    // Collision tileset
    tileset { _collision_tileset }

    set_focal_point(x, y, zoom) {
        _focal_x = x
        _focal_y = y
        _focal_zoom = zoom
    }

    create() {
        super.create()
        _rng = Random.new()
        Save.ui_scale = 2

        // Generate level
        _gen = Generator.new()
        _gen.tile_width = 24
        _gen.tile_height = 16
        _gen.tileset_tex = Assets.tex_tiles
        _gen.island_radius_max = 10
        _gen.island_radius_min = 3
        _gen.minimum_distance = _gen.island_radius_max * 1.5
        var tilesets = _gen.generate_level(75, 75, 13, this)
        _tileset = tilesets["ground"]
        _background_tileset = tilesets["background"]
        _foreground_tileset = tilesets["foreground"]
        _collision_tileset = tilesets["collisions"]

        // Tileset surface
        Renderer.use_cameras_on_surfaces = false
        Renderer.colour_mod = [1, 1, 1, 1]
        _tileset_surface = _background_tileset.draw_to_surface()
        Renderer.target = _tileset_surface
        _tileset.draw()
        _foreground_tileset.draw()
        _collision_tileset.draw()
        System.print("collisions %(_collision_tileset.width)/%(_collision_tileset.height)")
        System.print("ground %(_tileset.width)/%(_tileset.height)")
        Renderer.target = Renderer.RENDER_TARGET_DEFAULT

        
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
        _parallax_camera = Camera.new()
        var aspectRatio = Renderer.window_width / Renderer.window_height
        _game_camera.width = Constants.GAME_HEIGHT * aspectRatio
        _game_camera.height = Constants.GAME_HEIGHT
        _parallax_camera.width = Constants.GAME_HEIGHT * aspectRatio * 2
        _parallax_camera.height = Constants.GAME_HEIGHT * 2
        _game_camera.x = _player.x - (_game_camera.width / 2)
        _game_camera.y = _player.y - (_game_camera.height / 2)
        _parallax_camera.x = _player.x - (_parallax_camera.width / 2)
        _parallax_camera.y = _player.y - (_parallax_camera.height / 2)
        set_focal_point(_player.x, _player.y, 1)
        _window_surface = Surface.new(Renderer.window_width, Renderer.window_height)
    }

    pre_frame() {
        super.pre_frame()

        if (!is_paused || (is_paused && in_skill_check)) {
            // Calculate camera's width and height
            var aspectRatio = Renderer.window_width / Renderer.window_height
            var desired_width = (Constants.GAME_HEIGHT * aspectRatio) / _focal_zoom
            var desired_height = Constants.GAME_HEIGHT / _focal_zoom
            _game_camera.width = _game_camera.width + 0.05 * ((desired_width - _game_camera.width))
            _game_camera.height = _game_camera.height + 0.05 * ((desired_height - _game_camera.height))
            _game_camera.w_on_screen = Renderer.window_width
            _game_camera.h_on_screen = Renderer.window_height
            _game_camera.x = _game_camera.x + 0.05 * ((_focal_x - (_game_camera.width / 2)) - _game_camera.x)
            _game_camera.y = _game_camera.y + 0.05 * ((_focal_y - (_game_camera.height / 2)) - _game_camera.y)

            if (is_shaking) {
                _game_camera.x = _game_camera.x + _rng.float(-Constants.SHAKE_INTENSITY * _shake_intensity_modifier, Constants.SHAKE_INTENSITY * _shake_intensity_modifier)
                _game_camera.y = _game_camera.y + _rng.float(-Constants.SHAKE_INTENSITY * _shake_intensity_modifier, Constants.SHAKE_INTENSITY * _shake_intensity_modifier)
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

        // UI Camera
        _ui_camera.width = Renderer.window_width
        _ui_camera.height = Renderer.window_height
        _ui_camera.w_on_screen = Renderer.window_width
        _ui_camera.h_on_screen = Renderer.window_height

        // Parallax camera
        _parallax_camera.x = _parallax_camera.x + 0.05 * ((_focal_x - (_parallax_camera.width / 2)) - _parallax_camera.x)
        _parallax_camera.y = _parallax_camera.y + 0.05 * ((_focal_y - (_parallax_camera.height / 2)) - _parallax_camera.y)

        _parallax_camera.update()
        _ui_camera.update()
        _game_camera.update()

        // Update window surface if resized
        if (_window_surface.width != Renderer.window_width || _window_surface.height != Renderer.window_height) {
            _window_surface.free()
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
        Renderer.lock_cameras(_parallax_camera)
        draw_tiling_background(Assets.tex_background, 0.95)
        Renderer.lock_cameras(_game_camera)
        Renderer.draw_texture(_tileset_surface, 0, 0)

        // Props
        var new_props = []
        for (prop in _props) {
            if (!prop.update(this)) {
                new_props.add(prop)
            }
        }
        _props = new_props

        // Entities
        super.update()
        player.death_camera(this)
        for (cloud in _clouds_foreground) {
            cloud.draw(is_paused)
        }

        // Particles
        if (!is_paused) {
            var new_particles = []
            for (particle in _particles) {
                if (!particle.update()) {
                    new_particles.add(particle)
                }
            }
            _particles = new_particles
        }

        // Player UI
        Renderer.lock_cameras(_ui_camera)
        player.draw_ui(this)

        // Top-level game stuff
        process_meta()
        if (_skill_check != null) {
            if (_skill_check.update(_ui_camera)){ 
                _skill_check = null
            }
        }

        // Restart
        if ((player == null || player.is_dead) && _fade_out <= 0 && Controls.restart) {
            _fade_out = Constants.FADE_TIME
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
                if (_fade_out <= 0) {
                    Engine.switch_level(Game.new())
                }
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
        _window_surface.free()
        _tileset_surface.free()
    }
}