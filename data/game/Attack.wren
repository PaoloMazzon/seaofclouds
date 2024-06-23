import "Constants" for Constants

class Attack is Entity {
    construct new() { 
        super()
        _tied_entity = null
        _direction = 0
        _velocity_x = 0
        _velocity_y = 0
        _texture = null
        _lifespan = 0
        _team = Constants.TEAM_NONE
    }
    tied_entity=(s) { _tied_entity = s }
    direction=(s) { _direction = s }
    velocity_x=(s) { _velocity_x = s }
    velocity_y=(s) { _velocity_y = s }
    texture=(s) { _texture = s }
    lifespan=(s) { _lifespan = s }
    team=(s) { _team = s }
    team { _team }

    static create_attack(level, x, y, tied_entity, direction, velocity_x, velocity_y, texture, lifespan, team) {
        var e = level.add_entity(Attack)
        e.x = x
        e.y = y
        e.tied_entity = tied_entity
        e.direction = direction
        e.velocity_x = velocity_x
        e.velocity_y = velocity_y
        e.texture = texture
        e.lifespan = lifespan
        e.team = team
        var h = Hitbox.new_rectangle(texture.width, texture.height)
        h.x_offset = texture.width / 2
        h.y_offset = texture.height / 2
        e.hitbox = h
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            // Tie to entity
            if (_tied_entity != null) {
                x = _tied_entity.x
                y = _tied_entity.y
                if (_tied_entity.is_dead) {
                    level.remove_entity(this)
                }
            }

            // Lifespan timer
            _lifespan = _lifespan - Engine.delta
            if (_lifespan < 0) {
                level.remove_entity(this)
            }

            // Move
            x = x + (_velocity_x * _direction.cos)
            y = y + (_velocity_y * _direction.sin)
        }
    }

    draw(level) {
        super.draw(level)
        Renderer.draw_texture(_texture, x - (_texture.width / 2), y - (_texture.height / 2))
    }
}