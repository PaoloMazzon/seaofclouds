import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Save" for Save

class BlueSlime is Character {
    construct new() { 
        super() 
        _direction = 0
        _time = 0
        _max_time = 0
        team = Constants.TEAM_ENEMIES
        score_value = Constants.SLIME_SCORE_VALUE
        extra_lives = extra_lives + Constants.SLIME_EXTRA_LIVES
    }

    on_hit(level, attack) {
        super.on_hit(level, attack)
        level.add_particles(Assets.tex_slimeparticle, x, y, Math.point_angle(attack.x, attack.y, x, y), Num.pi * 0.3, 40, 1, Num.pi, 10)
    }

    // Picks a new direction to start moving in
    start_direction(level) {
        if (Math.point_distance(level.player.x, level.player.y, x, y) < Constants.SLIME_AGGRO_RANGE) {
            _direction = Math.point_angle(x, y, level.player.x, level.player.y)
            melee_attack(level, 5)
            var f = Fiber.new {
                Audio.play(Assets.aud_slimeattack, false, Save.volume, Save.volume)
            }
            set_alarm(5 * sprite_set.attack.delay, f)
        } else {
            _direction = _rng.float(Num.tau)
        }
        _time = _rng.float(Constants.SLIME_MIN_MOVE_TIME, Constants.SLIME_MAX_MOVE_TIME)
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
        melee_attack_texture = Assets.tex_slimeattack
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            if (_time > 0) {
                _time = is_telegraphing ? _time : _time - Engine.delta
                var percent = ((1 - (_time / _max_time)) - 1).pow(2)
                if (!is_telegraphing) {
                    velocity_x = Constants.SLIME_TOP_SPEED * percent * _direction.cos
                    velocity_y = Constants.SLIME_TOP_SPEED * percent * _direction.sin
                }

                if (_time <= 0) {
                    var f = Fiber.new {
                        start_direction(level)
                    }
                    set_alarm(_rng.float(Constants.SLIME_MIN_MOVE_TIME, Constants.SLIME_MAX_MOVE_TIME), f)
                }
            }
            process_physics(level)
        }
    }
}