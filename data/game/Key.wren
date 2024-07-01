import "Constants" for Constants
import "Save" for Save
import "FloatingText" for FloatingText

class Key is Entity {
    construct new() {
        super()
        _time = 0
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
    }

    update(level) {
        super.update(level)

        if (!level.is_paused) {
            if (_time > 1.2 && Math.point_distance(x, y, level.player.x, level.player.y) < 10 && !level.player.is_dead) {
                level.remove_entity(this)
                level.grab_key()
                FloatingText.create_floating_text(level, x, y, "Acquired key")
                Audio.play(Assets.aud_pickup, false, Save.volume, Save.volume)
            }

            _time = _time + Engine.delta
        }
    }

    jump(time) {
        return (-4 * (time - 0.5).pow(2)) + 1
    }

    draw(level) {
        var y_pos = y - 6 + (_time.sin * 3)
        var y_mod = 0
        if (_time < 0.25) {
            Renderer.colour_mod = [1, 1, 1, _time * 4]
        }
        if (_time < 1) {
            y_mod = -15 * jump(_time)
        }
        if (!level.is_paused) {
            Renderer.draw_sprite(Assets.spr_telegraph, x, y + y_mod)
        } else {
            Renderer.draw_sprite(Assets.spr_telegraph, Assets.spr_telegraph.frame, x, y + y_mod)
        }
        Renderer.draw_texture(Assets.tex_key, x - 4.5, y_pos + y_mod)
        Renderer.colour_mod = [1, 1, 1, 1]
    }

    
}