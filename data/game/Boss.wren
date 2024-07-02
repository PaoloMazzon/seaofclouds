import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Attack" for Attack
import "Alien" for Alien
import "Save" for Save

class Boss is Character {
    static STATE_WAIT { 0 }
    static STATE_RUN_N_GUN { 1 }
    static STATE_MELEE { 2 } // boss is a state machine
    static STATE_SPAWN_ALIEN { 3 }

    construct new() { 
        super() 
        _direction = 0
        _time = 0
        _max_time = 0
        team = Constants.TEAM_ENEMIES
        _player_last_known_x = 0
        _player_last_known_y = 0
        _state = Boss.STATE_WANDER
        _shoot_cooldown = 0
        _initial_shot_delay = 0
        _bowshot_sound = null
        score_value = Constants.RANGER_SCORE_VALUE
        extra_lives = extra_lives + Constants.RANGER_EXTRA_LIVES
    }

    spawn_alien(level) {
        var new_x = level.rng.float(x - Constants.BOSS_ALIEN_SPAWN_RADIUS, x + Constants.BOSS_ALIEN_SPAWN_RADIUS)
        var new_y = level.rng.float(y - Constants.BOSS_ALIEN_SPAWN_RADIUS, y + Constants.BOSS_ALIEN_SPAWN_RADIUS)
        var e = level.add_entity(Alien)
        e.x = new_x
        e.y = new_y
    }

    ranged_attack(level) {
        if (!level.player.is_dead && super.ranged_attack(level)) {
            var f = Fiber.new {
                if (!is_dead) {
                    var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                    var s_x = x + (4 * angle.cos)
                    var s_y = y + (4 * angle.sin)
                    Attack.create_attack(level, s_x, s_y, null, angle, Constants.RANGER_ARROW_SPEED * angle.cos, Constants.RANGER_ARROW_SPEED * angle.sin, Assets.tex_arrow, Constants.RANGER_ARROW_LIFETIME, Constants.TEAM_ENEMIES)
                }
            }
            set_alarm(sprite_set.ranged_attack.delay * 7, f)
            _bowshot_sound = Audio.play(Assets.aud_bowshot, false, Save.volume, Save.volume)
        }
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
        sprite_set = SpriteSet.BossSpriteSet
        _rng = level.rng
        start_direction()
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            if (_state == Boss.STATE_WANDER) {
                _time = _time - Engine.delta
                if (_time <= 0) {
                    if (!_walk) {
                        start_direction()
                    } else {
                        idle()
                    }
                }
                if (_walk) {
                    velocity_x = Constants.RANGER_WALK_SPEED * _direction.cos
                    velocity_y = Constants.RANGER_WALK_SPEED * _direction.sin
                }
            } else if (_state == Boss.STATE_SHOOT) {
                // If they go out of range switch to chase
                if (dist >= Constants.RANGER_AGGRO_RANGE) {
                    _state = Boss.STATE_CHASE
                    _time = _rng.float(Constants.RANGER_SEARCH_TIME_MIN, Constants.RANGER_SEARCH_TIME_MAX)
                }

                // Record last known position
                _player_last_known_x = level.player.x
                _player_last_known_y = level.player.y

                // Shoot in intervals
                _shoot_cooldown = _shoot_cooldown - Engine.delta
                _initial_shot_delay = _initial_shot_delay - Engine.delta
                if (_shoot_cooldown <= 0 && _initial_shot_delay <= 0) {
                    _shoot_cooldown = _rng.float(Constants.RANGER_MIN_SHOOT_COOLDOWN, Constants.RANGER_MAX_SHOOT_COOLDOWN)
                    ranged_attack(level)
                }
            } else if (_state == Boss.STATE_CHASE) {
                // Run towards last known locations
                if (Math.point_distance(_player_last_known_x, _player_last_known_y, x, y) > 5) {
                    var angle = Math.point_angle(x, y, _player_last_known_x, _player_last_known_y)
                    velocity_x = Constants.RANGER_RUN_SPEED * angle.cos
                    velocity_y = Constants.RANGER_RUN_SPEED * angle.sin
                }

                // Switch back to wander if search over
                _time = _time - Engine.delta
                if (_time <= 0) {
                    _state = Boss.STATE_WANDER
                    start_direction()
                }
            }
            process_physics(level)
        }
    }
}