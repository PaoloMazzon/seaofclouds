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
    tied_entity { _tied_entity }
    direction=(s) { _direction = s }
    velocity_x=(s) { _velocity_x = s }
    velocity_y=(s) { _velocity_y = s }
    texture=(s) { _texture = s }
    texture { _texture }
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
        return e
    }

    is_gone { _is_gone }

    kill() {
        _is_gone = true
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _is_gone = false
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            // Tie to entity
            if (_tied_entity != null) {
                x = _tied_entity.x
                y = _tied_entity.y
                var c = Engine.get_class("Character::Character")
                if (_tied_entity is c && _tied_entity.is_dead) {
                    level.remove_entity(this)
                    _is_gone = true
                }
            } else {
                // Move
                x = x + _velocity_x * Engine.delta
                y = y + _velocity_y * Engine.delta
            }

            // Lifespan timer
            _lifespan = _lifespan - Engine.delta
            if (_lifespan < 0) {
                level.remove_entity(this)
                _is_gone = true
            }
        }
    }

    draw(level) {
        super.draw(level)
        Renderer.draw_texture(_texture, x - (_texture.width / 2), y - (_texture.height / 2), 1, 1, _direction, (_texture.width / 2), (_texture.height / 2))
    }
}