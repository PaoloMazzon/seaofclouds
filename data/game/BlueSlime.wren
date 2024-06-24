import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls

class BlueSlime is Character {
    construct new() { 
        super() 
        _direction = 0
        _time = 0
        _max_time = 0
        team = Constants.TEAM_ENEMIES
    }

    // Picks a new direction to start moving in
    start_direction(level) {
        if (Math.point_distance(level.player.x, level.player.y, x, y) < Constants.SLIME_AGGRO_RANGE) {
            _direction = Math.point_angle(x, y, level.player.x, level.player.y)
            melee_attack(level)
        } else {
            _direction = _rng.float(Num.tau)
        }
        _time = _rng.float(1.5, 3.5)
        _max_time = _time
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.BlueSlimeSpriteSet
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
                var percent = ((1 - (_time / _max_time)) - 1).pow(2)
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