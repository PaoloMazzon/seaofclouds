import "Constants" for Constants
import "Save" for Save

class Knickknack is Entity {
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
            if (_time > 2 && Math.point_distance(x, y, level.player.x, level.player.y) < 10 && !level.player.is_dead) {
                level.remove_entity(this)
                level.grab_knickknack()
                Audio.play(Assets.aud_pickup, false, Save.volume, Save.volume)
            }

            _time = _time + Engine.delta
        }
    }

    draw(level) {
        if (_time < 1) {
            Renderer.colour_mod = [1, 1, 1, _time]
        }
        if (!level.is_paused) {
            Renderer.draw_sprite(Assets.spr_telegraph, x, y)
        } else {
            Renderer.draw_sprite(Assets.spr_telegraph, Assets.spr_telegraph.frame, x, y)
        }
        Renderer.draw_texture(level.knickknack_textures[level.knickknack_id], x - 4.5, y - 6 + (_time.sin * 3))
        Renderer.colour_mod = [1, 1, 1, 1]
    }
}