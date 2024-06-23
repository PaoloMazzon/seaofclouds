import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "BlueSlime" for BlueSlime

class Player is Character {
    construct new() { super() }

    on_hit(level) {
        var f = Fiber.new { |passed|
            if (!passed) {
                die()
            }
        }
        level.skill_check(Constants.SKILL_CHECK_EASY, f)
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.PlayerSpriteSet
        team = Constants.TEAM_PLAYER
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            velocity_x = Controls.movement_x * Constants.PLAYER_SPEED
            velocity_y = Controls.movement_y * Constants.PLAYER_SPEED
            process_physics(level)

            // Attack
            if (Controls.attack) {
                melee_attack(level)
            }

            // Debug
            if (Keyboard.key_pressed(Keyboard.KEY_O)) {
                on_hit(level)
            }
            if (Keyboard.key_pressed(Keyboard.KEY_L)) {
                var slime = level.add_entity(BlueSlime)
                slime.x = x
                slime.y = y
            }

            level.set_focal_point(x, y, level.in_skill_check || Keyboard.key(Keyboard.KEY_X) ? 2 : 1)
        }
    }
}