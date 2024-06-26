import "Attack" for Attack
import "Constants" for Constants

class Spikes is Entity {
    construct new() {
        super()
        _wait_timer = 0
        _attack_timer = 0
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_spikes.copy()
        sprite.origin_x = sprite.width / 2
        sprite.origin_y = sprite.height / 2
        sprite.delay = 0
        hitbox = Hitbox.new_rectangle(sprite.width, sprite.height)
        hitbox.x_offset = sprite.origin_x
        hitbox.y_offset = sprite.origin_y
    }

    update(level) {
        super.update(level)
    }

    draw(level) {
        if (!level.is_paused) {
            if (_wait_timer > 0 && _wait_timer - Engine.delta <= 0) {
                _attack_timer = 0.7
                Attack.create_attack(level, x, y, this, 0, 0, 0, Assets.tex_spikehitbox, 0.7, Constants.TEAM_ENEMIES)
            }

            _wait_timer = _wait_timer - Engine.delta
            _attack_timer = _attack_timer - Engine.delta

            if (colliding(level.player) && !level.player.is_dead && _wait_timer <= 0 && _attack_timer <= 0) {
                _wait_timer = Constants.SPIKES_DELAY
            }
        }

        if (_wait_timer <= 0 && _attack_timer <= 0) {
            Renderer.draw_sprite(sprite, 0, x, y)
        } else if (_wait_timer > 0 && _attack_timer <= 0) {
            Renderer.draw_sprite(sprite, 1, x, y)
        } else if (_wait_timer <= 0 && _attack_timer > 0) {
            Renderer.draw_sprite(sprite, 2 + (_attack_timer / 0.1).floor, x, y)
        }
    }
}