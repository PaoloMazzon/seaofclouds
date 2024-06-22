import "Constants" for Constants

class SpriteSet {
    construct new(walk_left, walk_right, idle_left, idle_right, hit_left, hit_right, attack_left, attack_right, die) {
        _walk_left = walk_left
        _walk_right = walk_right
        _idle_left = idle_left
        _idle_right = idle_right
        _hit_left = hit_left
        _hit_right = hit_right
        _attack_left = attack_left
        _attack_right = attack_right
        _die = die
    }

    walk_left { _walk_left }
    walk_left=(s) { _walk_left = s }
    walk_right { _walk_right }
    walk_right=(s) { _walk_right = s }
    idle_left { _idle_left }
    idle_left=(s) { _idle_left = s }
    idle_right { _idle_right }
    idle_right=(s) { _idle_right = s }
    hit_left { _hit_left }
    hit_left=(s) { _hit_left = s }
    hit_right { _hit_right }
    hit_right=(s) { _hit_right = s }
    attack_left { _attack_left }
    attack_left=(s) { _attack_left = s }
    attack_right { _attack_right }
    attack_right=(s) { _attack_right = s }
    die { _die }
    die=(s) { _die = s }
    walk(facing) { facing == -1 ? _walk_left : _walk_right }
    idle(facing) { facing == -1 ? _idle_left : _idle_right }
    hit(facing) { facing == -1 ?_hit_left : _hit_right }
    attack(facing) { facing == -1 ? at_attack_left : _attack_right }

    static PlayerSpriteSet {
        return SpriteSet.new(
            Assets.spr_player_walk_left.copy(),
            Assets.spr_player_walk_right.copy(),
            Assets.spr_player_idle_left.copy(),
            Assets.spr_player_idle_right.copy(),
            Assets.spr_player_hit_left,
            Assets.spr_player_hit_right.copy(),
            null,
            null,
            Assets.spr_player_die.copy()
        )
    }
}

class Character is Entity {
    construct new() { 
        super()
        _facing_x = 1
        _velocity_x = 0
        _velocity_y = 0
        _sprite_set = null
    }

    sprite_set { _sprite_set }
    sprite_set=(s) { _sprite_set = s }
    velocity_x { _velocity_x }
    velocity_x=(s) { _velocity_x = s }
    velocity_y { _velocity_y }
    velocity_y=(s) { _velocity_y = s }
    facing_left { _facing_x == -1 }
    facing_right { _facing_x == 1 }

    process_physics() {
        // Facing
        if (velocity_x > 0) {
            _facing_x = 1
        } else if (velocity_x < 0) {
            _facing_x = -1
        }

        x = x + (velocity_x * Engine.delta)
        y = y + (velocity_y * Engine.delta)
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            velocity_x = 0
            velocity_y = 0
        }
    }

    draw_sprite(sprite, x, y, paused) {
        if (paused) {
            Renderer.draw_sprite(sprite, sprite.frame, x, y)
        } else {
            Renderer.draw_sprite(sprite, x, y)
        }
    }

    draw(level) {
        super.draw(level)
        
        // Animations
        if (velocity_x == 0 && velocity_y == 0) {
            draw_sprite(sprite_set.idle(_facing_x), x, y, level.is_paused)
        } else {
            draw_sprite(sprite_set.walk(_facing_x), x, y, level.is_paused)
        }
    }
}