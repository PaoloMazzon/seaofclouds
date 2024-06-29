import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Attack" for Attack
import "Save" for Save

class Fighter is Character {
    static STATE_WANDER { 0 }
    static STATE_CIRCLE_PLAYER { 1 }
    static STATE_CHARGE { 2 }
    static STATE_CHASE { 3 } // fighter is a state machine

    construct new() { 
        super() 
        _direction = 0
        _time = 0
        _max_time = 0
        team = Constants.TEAM_ENEMIES
        _player_last_known_x = 0
        _player_last_known_y = 0
        _state = Fighter.STATE_WANDER
        _shoot_cooldown = 0
        _circle_time = 0
        _bowshot_sound = null
        score_value = Constants.FIGHTER_SCORE_VALUE
        _circling_angle = 0 // for circling player
        _fighter_charge_timer = 0
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
        sprite_set = SpriteSet.FighterSpriteSet
        _rng = level.rng
        _circling_angle = level.rng.float(Num.tau)
        start_direction()
        _circling_sign = 1
        _circling_switch_time = level.rng.float(1)
        melee_attack_texture = Assets.tex_fighterattack
    }

    enter_circling(level) {
        _state = Fighter.STATE_CIRCLE_PLAYER
        _circle_time = level.rng.float(Constants.FIGHTER_MIN_CIRCLE_TIME, Constants.FIGHTER_MAX_CIRCLE_TIME)
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

            // Always on guard for the player
            var dist = Math.point_distance(level.player.x, level.player.y, x, y)
            if (dist < Constants.FIGHTER_AGGRO_RANGE && (_state == Fighter.STATE_WANDER || _state == Fighter.STATE_CHASE)) {
                enter_circling(level)
            }

            // If the player is dead don't circle them
            if (level.player.is_dead) {
                _state = Fighter.STATE_WANDER
            }

            if (_state == Fighter.STATE_WANDER) {
                _time = _time - Engine.delta
                if (_time <= 0) {
                    if (!_walk) {
                        start_direction()
                    } else {
                        idle()
                    }
                }
                if (_walk) {
                    velocity_x = Constants.FIGHTER_WALK_SPEED * _direction.cos
                    velocity_y = Constants.FIGHTER_WALK_SPEED * _direction.sin
                }
            } else if (_state == Fighter.STATE_CIRCLE_PLAYER || _state == Fighter.STATE_CHARGE) {
                // If they go out of range switch to chase
                if (dist >= Constants.FIGHTER_AGGRO_RANGE_IN_FIGHT) {
                    _state = Fighter.STATE_CHASE
                    _time = _rng.float(Constants.FIGHTER_SEARCH_TIME_MIN, Constants.FIGHTER_SEARCH_TIME_MAX)
                }

                // Record last known position
                _player_last_known_x = level.player.x
                _player_last_known_y = level.player.y

                if (_state == Fighter.STATE_CHARGE) {
                    // Charge the player while attacking
                    _fighter_charge_timer = _fighter_charge_timer - Engine.delta
                    if (_fighter_charge_timer <= 0) {
                        enter_circling(level)
                    }

                    if (dist > 5) {
                        var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                        velocity_x = Constants.FIGHTER_CHARGE_SPEED * angle.cos
                        velocity_y = Constants.FIGHTER_CHARGE_SPEED * angle.sin
                    }
                } else {
                    // Move in a circle around the player
                    _circle_time = _circle_time - Engine.delta
                    var target_x = level.player.x + (Constants.FIGHTER_CIRCLE_DISTANCE * _circling_angle.cos)
                    var target_y = level.player.y + (Constants.FIGHTER_CIRCLE_DISTANCE * _circling_angle.sin)
                    if (Math.point_distance(x, y, target_x, target_y) > 5) {
                        var angle = Math.point_angle(x, y, target_x, target_y)
                        velocity_x = Constants.FIGHTER_RUN_SPEED * angle.cos
                        velocity_y = Constants.FIGHTER_RUN_SPEED * angle.sin
                    }

                    // Attack
                    if (_circle_time <= 0 && !is_dead) {
                        _state = Fighter.STATE_CHARGE
                        _fighter_charge_timer = Constants.FIGHTER_CHARGE_TIME
                        melee_attack(level, 6)
                        Audio.play(Assets.aud_fighterattack, false, Save.volume, Save.volume)
                    }
                }
            } else if (_state == Fighter.STATE_CHASE) {
                // Run towards last known locations
                if (Math.point_distance(_player_last_known_x, _player_last_known_y, x, y) > 5) {
                    var angle = Math.point_angle(x, y, _player_last_known_x, _player_last_known_y)
                    velocity_x = Constants.FIGHTER_RUN_SPEED * angle.cos
                    velocity_y = Constants.FIGHTER_RUN_SPEED * angle.sin
                }

                // Switch back to wander if search over
                _time = _time - Engine.delta
                if (_time <= 0) {
                    _state = Fighter.STATE_WANDER
                    start_direction()
                }
            }
            process_physics(level)
        }
    }
}