import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "BlueSlime" for BlueSlime

class Player is Character {
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.PlayerSpriteSet
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
                die()
            }
            if (Keyboard.key_pressed(Keyboard.KEY_L)) {
                var slime = level.add_entity(BlueSlime)
                slime.x = x
                slime.y = y
            }

            level.set_focal_point(x, y, 1)
        }
    }
}