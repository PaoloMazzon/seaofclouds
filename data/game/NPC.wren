import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls

class NPC is Character {
    construct new() { 
        super()
        _direction = 0
        _time = 0
        _max_time = 0
        _start_x = 0
        _start_y = 0
        team = Constants.TEAM_ENEMIES
    }

    on_hit(level, attack) {
        super.on_hit(level, attack)
        level.add_particles(Assets.tex_humanparticle, x, y, Math.point_angle(attack.x, attack.y, x, y), Num.pi * 0.3, 40, 1, Num.pi, 10)
    }

    // Picks a new direction to start moving in
    start_direction(level) {
        if (Math.point_distance(x, y, _start_x, _start_y) < Constants.NPC_MAX_WANDER_DISTANCE) {
            _direction = _rng.float(Num.tau)
        } else {
            _direction = Math.point_angle(x, y, _start_x, _start_y)
        }
        _time = _rng.float(1.5, 3.5)
        _max_time = _time
    }

    set_start_location(start_x, start_y) {
        x = start_x
        y = start_y
        _start_x = start_x
        _start_y = start_y
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = level.rng.sample([SpriteSet.NPC1SpriteSet, SpriteSet.NPC2SpriteSet, SpriteSet.NPC3SpriteSet, SpriteSet.NPC4SpriteSet])
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
                _time = is_telegraphing ? _time : _time - Engine.delta
                var percent = 1
                velocity_x = Constants.SLIME_TOP_SPEED * percent * _direction.cos
                velocity_y = Constants.SLIME_TOP_SPEED * percent * _direction.sin

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