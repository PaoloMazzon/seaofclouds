import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Attack" for Attack

class Ranger is Character {
    construct new() { 
        super() 
        _direction = 0
        _time = 0
        _max_time = 0
        _walk = true
        team = Constants.TEAM_ENEMIES
    }

    on_hit(level, attack) {
        super.on_hit(level, attack)
        level.add_particles(Assets.tex_humanparticle, x, y, Math.point_angle(attack.x, attack.y, x, y), Num.pi * 0.3, 40, 1, Num.pi, 10)
    }

    // Picks a new direction to start moving in
    start_direction(level) {
        if (Math.point_distance(level.player.x, level.player.y, x, y) < Constants.RANGER_AGGRO_RANGE) {
            if (ranged_attack(level)) {
                var f = Fiber.new {
                    var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                    var s_x = x + (4 * angle.cos)
                    var s_y = y + (4 * angle.sin)
                    System.print(s_x)
                    Attack.create_attack(level, s_x, s_y, null, angle, Constants.ENEMY_ARROW_SPEED * angle.cos, Constants.ENEMY_ARROW_SPEED * angle.sin, Assets.tex_arrow, Constants.ENEMY_ARROW_LIFETIME, Constants.TEAM_ENEMIES)
                }
                set_alarm(sprite_set.ranged_attack.delay * 7, f)
            }
            _walk = false
        } else {
            _direction = _rng.float(Num.tau)
            _walk = true
        }
        _time = _rng.float(1.5, 3.5)
        _max_time = _time
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.RangerSpriteSet
        _rng = level.rng
        var f = Fiber.new {
            start_direction(level)
        }
        set_alarm(_rng.float(), f)
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            if (_time > 0) {
                _time = _time - Engine.delta
                if (_walk) {
                    velocity_x = Constants.RANGER_WALK_SPEED * _direction.cos
                    velocity_y = Constants.RANGER_WALK_SPEED * _direction.sin
                }

                if (_time <= 0) {
                    var f = Fiber.new {
                        start_direction(level)
                    }
                    set_alarm(_rng.float(0.5, 3), f)
                }
            }
            process_physics(level)
        }
    }
}