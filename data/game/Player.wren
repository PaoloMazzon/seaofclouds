import "Constants" for Constants
import "Character" for Character, SpriteSet

class Player is Character {
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.PlayerSpriteSet
    }

    update(level) {
        super.update(level)
        velocity_x = Keyboard.keys_as_axis(Keyboard.KEY_LEFT, Keyboard.KEY_RIGHT) * Engine.delta * Constants.PLAYER_SPEED
        velocity_y = Keyboard.keys_as_axis(Keyboard.KEY_UP, Keyboard.KEY_DOWN) * Engine.delta * Constants.PLAYER_SPEED
        process_physics()
    }
}