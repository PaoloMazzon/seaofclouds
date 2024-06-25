import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Attack" for Attack

class Ranger is Character {
    static STATE_WANDER { 0 }
    static STATE_SHOOT { 1 }
    static STATE_CHASE { 2 } // ranger is a state machine

    construct new() { 
        super() 
        _direction = 0
        _time = 0
        _max_time = 0
        team = Constants.TEAM_ENEMIES
        _player_last_known_x = 0
        _player_last_known_y = 0
        _state = Ranger.STATE_WANDER
    }

    ranged_attack(level) {
        if (super.ranged_attack(level)) {
            var f = Fiber.new {
                var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                var s_x = x + (4 * angle.cos)
                var s_y = y + (4 * angle.sin)
                System.print(s_x)
                Attack.create_attack(level, s_x, s_y, null, angle, Constants.ENEMY_ARROW_SPEED * angle.cos, Constants.ENEMY_ARROW_SPEED * angle.sin, Assets.tex_arrow, Constants.ENEMY_ARROW_LIFETIME, Constants.TEAM_ENEMIES)
            }
            set_alarm(sprite_set.ranged_attack.delay * 7, f)
        }
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
        sprite_set = SpriteSet.RangerSpriteSet
        _rng = level.rng
        start_direction()
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            // Always on guard for the player
            if (Math.point_distance(level.player.x, level.player.y, x, y) < Constants.RANGER_AGGRO_RANGE) {
                _state = Ranger.STATE_SHOOT
            }

            if (_state == Ranger.STATE_WANDER) {
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
            } else if (_state == Ranger.STATE_SHOOT) {
                if (Math.point_distance(level.player.x, level.player.y, x, y) >= Constants.RANGER_AGGRO_RANGE) {
                    _state = Ranger.STATE_CHASE
                }
                _player_last_known_x = level.player.x
                _player_last_known_y = level.player.y
            } else if (_state == Ranger.STATE_CHASE) {

            }
            process_physics(level)
        }
    }
}