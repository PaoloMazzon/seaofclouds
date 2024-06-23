import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls

class BlueSlime is Character {
    construct new() { 
        super() 
        _direction = 0
        _time = 0
    }

    // Picks a new direction to start moving in
    start_direction(level) {
        if (Math.point_distance(level.player.x, level.player.y, x, y) < 150) {
            _direction = Math.point_angle(x, y, level.player.x, level.player.y)
        } else {
            _direction = _rng.float(Num.tau)
        }
        _time = _rng.float(1, 3)
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.BlueSlimeSpriteSet
        _rng = level.rng
        var f = Fiber.new {
            start_direction(level)
        }
        set_alarm(_rng.float(1, 3), f)
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            if (_time > 0) {
                _time = _time - Engine.delta
                velocity_x = 20 * _direction.cos
                velocity_y = 20 * _direction.sin

                if (_time <= 0) {
                    var f = Fiber.new {
                        start_direction(level)
                    }
                    set_alarm(_rng.float(1, 3), f)
                }
            }
            process_physics(level)
        }
    }
}