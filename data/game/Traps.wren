import "Attack" for Attack
import "Save" for Save
import "Constants" for Constants
import "Rogue" for Bomb

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
                Attack.create_attack(level, x, y, this, 0, 0, 0, Assets.tex_spikehitbox, 0.7, Constants.TEAM_TRAPS)
            }

            _wait_timer = _wait_timer - Engine.delta
            _attack_timer = _attack_timer - Engine.delta

            if (colliding(level.player) && !level.player.is_dead && _wait_timer <= 0 && _attack_timer <= 0) {
                _wait_timer = Constants.SPIKES_DELAY
                Audio.play(Assets.aud_spikes, false, Save.volume, Save.volume)
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

class FastSpikes is Entity {
    construct new() {
        super()
        _wait_timer = 0
        _attack_timer = 0
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_fastspikes.copy()
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
                Attack.create_attack(level, x, y, this, 0, 0, 0, Assets.tex_spikehitbox, 0.7, Constants.TEAM_TRAPS)
            }

            _wait_timer = _wait_timer - Engine.delta
            _attack_timer = _attack_timer - Engine.delta

            if (colliding(level.player) && !level.player.is_dead && _wait_timer <= 0 && _attack_timer <= 0) {
                _wait_timer = Constants.FAST_SPIKES_DELAY
                Audio.play(Assets.aud_spikes, false, Save.volume, Save.volume)
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

class Teleporter is Entity {
    construct new() {
        super()
        _sprite_timer = 0
        _zoom_timer = 0
        _drop_x = 0
        _drop_y = 0
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_teleport.copy()
        sprite.origin_x = sprite.width / 2
        sprite.origin_y = sprite.height / 2
    }

    update(level) {
        super.update(level)

        if (Math.point_distance(x, y, level.player.x, level.player.y) < 15 && _zoom_timer <= 0) {
            level.player.x = x
            level.player.y = y
            level.chest_open(sprite.frame_count * sprite.delay * 2.2)
            _sprite_timer = sprite.frame_count * sprite.delay
            _zoom_timer = _sprite_timer * 2.2
            Audio.play(Assets.aud_teleport, false, Save.volume, Save.volume)

            // Find a spot to put the player
            var found_spot = false
            var x = 0
            var y = 0
            while (!found_spot) {
                x = level.rng.int(level.tileset.tiles_wide)
                y = level.rng.int(level.tileset.tiles_tall)
                found_spot = level.tileset[x, y] == 0
            }

            _drop_x = x * level.tileset.tile_width + (level.tileset.tile_width / 2)
            _drop_y = y * level.tileset.tile_height + (level.tileset.tile_height / 2)
        }

        if (_zoom_timer > 0) {
            _sprite_timer = _sprite_timer - Engine.delta
            _zoom_timer = _zoom_timer - Engine.delta
            level.set_focal_point(level.player.x, level.player.y, 2)

            // Drop the player in his spot
            if (_sprite_timer <= 0) {
                level.player.x = _drop_x
                level.player.y = _drop_y
            }
        }
    }

    draw(level) {
        Renderer.draw_sprite(sprite, _sprite_timer > 0 ? ((_sprite_timer) / sprite.delay).floor : 0, x, y)
    }
}

class BombPlant is Entity {
    construct new() {
        super()
        _sprite_timer = 0
        _zoom_timer = 0
        _drop_x = 0
        _drop_y = 0
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _index = level.rng.sample([4, 5, 6])
    }

    update(level) {
        super.update(level)

        for (attack in level.get_entities(Attack)) {
            if (Math.point_distance(attack.x, attack.y, x, y) < attack.hitbox.w) {
                level.add_particles(Assets.tex_plantparticle, x, y, Math.point_angle(attack.x, attack.y, x, y), Num.pi * 0.3, 50, 1, Num.pi, 8)
                Audio.play(Assets.aud_plantcut, false, Save.volume, Save.volume)
                Save.total_props_destroyed = Save.total_props_destroyed + 1
                Bomb.throw_bomb(level, x, y, 0, 0, 0, Constants.PLANT_TRAP_DETONATION_TIMER)
                level.remove_entity(this)
            }
        }
    }

    draw(level) {
        Renderer.draw_sprite(Assets.spr_props, _index, x, y)
    }
}