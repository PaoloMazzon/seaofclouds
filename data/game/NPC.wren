import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Save" for Save
import "Chest" for Chest

class NPC is Character {
    construct new() { 
        super()
        _direction = 0
        _time = 0
        _max_time = 0
        _start_x = 0
        _start_y = 0
        _speech_animation = 0
        _happy = false
        team = Constants.TEAM_ENEMIES
        score_value = Constants.NPC_SCORE_VALUE
    }

    on_hit(level, attack) {
        super.on_hit(level, attack)
        Save.total_npcs_killed = Save.total_npcs_killed + 1
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
                if (Math.point_distance(x, y, level.player.x, level.player.y) >= 40 || _happy) {
                    velocity_x = Constants.NPC_TOP_SPEED * percent * _direction.cos
                    velocity_y = Constants.NPC_TOP_SPEED * percent * _direction.sin
                }

                if (_time <= 0) {
                    var f = Fiber.new {
                        start_direction(level)
                    }
                    set_alarm(_rng.float(0.5, 3), f)
                }
            }
            if (Math.point_distance(x, y, level.player.x, level.player.y) < 40) {
                if (level.has_knickknack && !_happy) {
                    _happy = true
                    level.remove_knickknack()
                    Audio.play(Assets.aud_pickup, false, Save.volume, Save.volume)
                    level.player.award_score(Constants.NPC_GIVE_ITEM_SCORE)
                    var e = level.add_entity(Chest)
                    e.x = x
                    e.y = y
                } else {
                    _speech_animation = _speech_animation + Engine.delta > 0.5 ? 0.5 : _speech_animation + Engine.delta
                }
            } else {
                _speech_animation = 0
            }

            process_physics(level)
        }
    }

    draw(level) {
        super.draw(level)

        if (_happy && !is_dead) {
            _speech_animation = _speech_animation + Engine.delta > 0.5 ? 0.5 : _speech_animation + Engine.delta
            var percent = Math.serp(_speech_animation * 2, 0, 1)
            Renderer.colour_mod = [1, 1, 1, percent]
            Renderer.draw_texture(Assets.tex_happy, x - 12, y - (12 + (10 * percent)))
            Renderer.colour_mod = [1, 1, 1, 1]
        } else if (_speech_animation > 0 && !is_dead) {
            var percent = Math.serp(_speech_animation * 2, 0, 1)
            Renderer.colour_mod = [1, 1, 1, percent]
            Renderer.draw_texture(Assets.tex_speechbubble, x - 12, y - (12 + (10 * percent)))
            Renderer.draw_texture(level.knickknack_textures[level.knickknack_id], x - 10, y - (12 + (10 * percent)) + 3)
            Renderer.colour_mod = [1, 1, 1, 1]
        }
    }
}