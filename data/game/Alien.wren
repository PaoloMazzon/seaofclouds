import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Attack" for Attack
import "Save" for Save

class Alien is Character {
    static STATE_WAIT { 0 }
    static STATE_CIRCLE_PLAYER { 1 }
    static STATE_CHARGE { 2 }
    static STATE_CHASE { 3 } // alien is a state machine

    construct new() { 
        super() 
        _direction = 0
        _time = 0
        _max_time = 0
        team = Constants.TEAM_ENEMIES
        _player_last_known_x = 0
        _player_last_known_y = 0
        _state = Alien.STATE_WAIT
        _shoot_cooldown = 0
        _circle_time = 0
        _bowshot_sound = null
        score_value = Constants.ALIEN_SCORE_VALUE
        _circling_angle = 0 // for circling player
        _alien_charge_timer = 0
        extra_lives = extra_lives + Constants.ALIEN_EXTRA_LIVES
    }

    die() {
        super.die()
        // _bowshot_sound.stop() - might cause crashes not sure
    }

    on_hit(level, attack) {
        super.on_hit(level, attack)
        level.add_particles(Assets.tex_humanparticle, x, y, Math.point_angle(attack.x, attack.y, x, y), Num.pi * 0.3, 40, 1, Num.pi, 10)
    }

    // Picks a new direction to start moving in for wander phase
    start_direction() {
        _direction = _rng.float(Num.tau)
        _time = _rng.float(1.5, 3.5)
        _walk = true
        _max_time = _time
    }

    // Same as above but idle instead of walking around
    idle() {
        _time = _rng.float(1.5, 3.5)
        _walk = false
        _max_time = _time
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.AlienSpriteSet
        _rng = level.rng
        _circling_angle = level.rng.float(Num.tau)
        start_direction()
        _circling_sign = 1
        _circling_switch_time = level.rng.float(1)
        melee_attack_texture = Assets.tex_fighterattack
        _idle_spr = sprite_set.idle
        _player_dead_timer = 0
    }

    enter_circling(level) {
        _state = Alien.STATE_CIRCLE_PLAYER
        _circle_time = level.rng.float(Constants.ALIEN_MIN_CIRCLE_TIME, Constants.ALIEN_MAX_CIRCLE_TIME)
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            // Process circling counters
            _circling_angle = _circling_angle + (Engine.delta * _circling_sign)
            _circling_switch_time = _circling_switch_time + Engine.delta
            if (_circling_switch_time >= 1) {
                if (level.rng.int(2) == 1) {
                    _circling_sign = -_circling_sign
                }
                _circling_switch_time = 0
            }
            var dist = Math.point_distance(level.player.x, level.player.y, x, y)
            
            // If the player is dead don't circle them
            if (level.player.is_dead) {
                _state = Alien.STATE_WAIT
                sprite_set.idle = _idle_spr
                _player_dead_timer = _player_dead_timer + (Engine.delta * 0.5)
            }

            if (_state == Alien.STATE_WAIT) {
                if (!level.player.is_dead) {
                    ranged_attack(level)
                    var f = Fiber.new {
                        _state = Alien.STATE_CHASE
                    }
                    sprite_set.idle = sprite_set.walk
                    set_alarm(sprite_set.ranged_attack.delay * sprite_set.ranged_attack.frame_count, f)
                }
            } else if (_state == Alien.STATE_CIRCLE_PLAYER || _state == Alien.STATE_CHARGE) {
                // If they go out of range switch to chase
                if (dist >= Constants.ALIEN_AGGRO_RANGE_IN_FIGHT) {
                    _state = Alien.STATE_CHASE
                    _time = _rng.float(Constants.ALIEN_SEARCH_TIME_MIN, Constants.ALIEN_SEARCH_TIME_MAX)
                }

                // Record last known position
                _player_last_known_x = level.player.x
                _player_last_known_y = level.player.y

                if (_state == Alien.STATE_CHARGE) {
                    // Charge the player while attacking
                    _alien_charge_timer = _alien_charge_timer - Engine.delta
                    if (_alien_charge_timer <= 0) {
                        enter_circling(level)
                    }

                    if (dist > 5) {
                        var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                        velocity_x = Constants.ALIEN_CHARGE_SPEED * angle.cos
                        velocity_y = Constants.ALIEN_CHARGE_SPEED * angle.sin
                    }
                } else {
                    if (Math.point_distance(level.player.x, level.player.y, x, y) > Constants.ALIEN_ENTER_CIRCLING) {
                        _state = Alien.STATE_CHASE
                    }

                    // Move in a circle around the player
                    _circle_time = _circle_time - Engine.delta
                    var target_x = level.player.x + (Constants.ALIEN_CIRCLE_DISTANCE * _circling_angle.cos)
                    var target_y = level.player.y + (Constants.ALIEN_CIRCLE_DISTANCE * _circling_angle.sin)
                    if (Math.point_distance(x, y, target_x, target_y) > 5) {
                        var angle = Math.point_angle(x, y, target_x, target_y)
                        velocity_x = Constants.ALIEN_RUN_SPEED * angle.cos
                        velocity_y = Constants.ALIEN_RUN_SPEED * angle.sin
                    }

                    // Attack
                    if (_circle_time <= 0 && !is_dead) {
                        _state = Alien.STATE_CHARGE
                        _alien_charge_timer = Constants.ALIEN_CHARGE_TIME
                        melee_attack(level, 6)
                        Audio.play(Assets.aud_fighterattack, false, Save.volume, Save.volume)
                    }
                }
            } else if (_state == Alien.STATE_CHASE) {
                // Run towards last known locations
                if (Math.point_distance(level.player.x, level.player.y, x, y) > Constants.ALIEN_ENTER_CIRCLING) {
                    var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                    velocity_x = Constants.ALIEN_RUN_SPEED * angle.cos
                    velocity_y = Constants.ALIEN_RUN_SPEED * angle.sin
                } else {
                    _state = Alien.STATE_CIRCLE_PLAYER
                }
            }
            process_physics(level)
        }
    }

    draw(level) {
        super.draw(level)
        var percent = Math.serp(_player_dead_timer, 0.5, 1)
        Renderer.colour_mod = [1, 1, 1, _player_dead_timer < 0.5 ? _player_dead_timer * 2 : 1]
        Renderer.draw_texture(Assets.tex_happy, x - 12, y - (12 + (10 * percent)))
        Renderer.colour_mod = [1, 1, 1, 1]
    }
}