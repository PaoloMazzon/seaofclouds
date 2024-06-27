import "Constants" for Constants
import "Save" for Save
import "Attack" for Attack
import "Knickknack" for Knickknack

class Alarm {
    construct new(time, fiber) {
        _time = time
        _fiber = fiber
        _max = time
    }

    // Returns true if the alarm is done
    update() {
        _time = _time - Engine.delta
        if (_time <= 0) {
            _fiber.call()
            return true
        }
        return false
    }

    // Returns a value from 0-1 where 1 is this alarm is about to go off and 0 it just got set
    get_normalized_time() {
        return 1 - (_time / _max)
    }
}

class SpriteSet {
    construct new(walk, idle, attack, ranged_attack, die) {
        _walk = walk
        _idle = idle
        _attack = attack
        _ranged_attack = ranged_attack
        _die = die
    }

    walk { _walk }
    walk=(s) { _walk = s }
    idle { _idle }
    idle=(s) { _idle = s }
    attack { _attack }
    attack=(s) { _attack = s }
    ranged_attack { _ranged_attack }
    ranged_attack=(s) { _ranged_attack = s }
    die { _die }
    die=(s) { _die = s }

    static PlayerSpriteSet {
        return SpriteSet.new(
            Assets.spr_player_walk.copy(),
            Assets.spr_player_idle.copy(),
            Assets.spr_player_attack.copy(),
            Assets.spr_player_throw.copy(),
            Assets.spr_player_die.copy()
        )
    }

    static BlueSlimeSpriteSet {
        return SpriteSet.new(
            Assets.spr_blueslime_walk.copy(),
            Assets.spr_blueslime_idle.copy(),
            Assets.spr_blueslime_attack.copy(),
            null,
            Assets.spr_blueslime_die.copy()
        )
    }

    static RangerSpriteSet {
        return SpriteSet.new(
            Assets.spr_ranger_walk.copy(),
            Assets.spr_ranger_idle.copy(),
            null,
            Assets.spr_ranger_attack.copy(),
            Assets.spr_ranger_die.copy()
        )
    }

    static NPC1SpriteSet {
        return SpriteSet.new(
            Assets.spr_npc1_walk.copy(),
            Assets.spr_npc1_idle.copy(),
            null,
            null,
            Assets.spr_npc1_die.copy()
        )
    }

    static NPC2SpriteSet {
        return SpriteSet.new(
            Assets.spr_npc2_walk.copy(),
            Assets.spr_npc2_idle.copy(),
            null,
            null,
            Assets.spr_npc2_die.copy()
        )
    }

    static NPC3SpriteSet {
        return SpriteSet.new(
            Assets.spr_npc3_walk.copy(),
            Assets.spr_npc3_idle.copy(),
            null,
            null,
            Assets.spr_npc3_die.copy()
        )
    }

    static NPC4SpriteSet {
        return SpriteSet.new(
            Assets.spr_npc4_walk.copy(),
            Assets.spr_npc4_idle.copy(),
            null,
            null,
            Assets.spr_npc4_die.copy()
        )
    }
}

class Character is Entity {
    construct new() { 
        super()
        _facing_x = 1
        _moving_x = 0
        _moving_y = 0
        _velocity_x = 0
        _velocity_y = 0
        _sprite_set = null
        hitbox = Hitbox.new_rectangle(8, 6)
        hitbox.x_offset = 4
        hitbox.y_offset = 3
        _attack_timer = 0
        _death_timer = 0
        _has_died = false
        _team = Constants.TEAM_NONE
        _alarms = []
        _sprite_override = null
        _invincible = false
        _alternator = false
        _alternator_time = 0
        _ranged_attack = false
        _sprite_timer = 0
        _has_knickknack = false
        _dont_flicker = false
        _sprite_effect = null
        _melee_attack = null
        _melee_attack_texture = null
        _score_value = 0
    }

    score_value { _score_value }
    score_value=(s) { _score_value = s }
    sprite_effect { _sprite_effect }
    sprite_effect=(s) { _sprite_effect = s }
    sprite_set { _sprite_set }
    sprite_set=(s) { _sprite_set = s }
    velocity_x { _velocity_x }
    velocity_x=(s) { _velocity_x = s }
    velocity_y { _velocity_y }
    velocity_y=(s) { _velocity_y = s }
    team { _team }
    team=(s) { _team = s }
    facing_left { _facing_x == -1 }
    facing_right { _facing_x == 1 }
    facing { _facing_x }
    is_attacking { _attack_timer > 0 }
    is_telegraphing { _attack_timer <= 0 && _sprite_timer > 0 }
    is_invincible { _invincible }
    moving_x { _moving_x }
    moving_y { _moving_y }
    melee_attack_entity { _melee_attack }
    melee_attack_texture { _melee_attack_texture }
    melee_attack_texture=(s) { _melee_attack_texture = s }

    // Sets a sprite to be used instead of anything else, setting this to null will go back to normal
    sprite_override=(sprite) { _sprite_override = sprite }
    sprite_override { _sprite_override }

    // Assigns this character the knickknack
    give_knickknack() {
        _has_knickknack = true
    }

    // Makes a character invincible for a short time
    make_invincible(time) {
        _invincible = true
        var f = Fiber.new {
            _invincible = false
        }
        _dont_flicker = false
        set_alarm(time, f)
    }

    make_invincible_no_flicker(time) {
        make_invincible(time)
        _dont_flicker = true
    }

    // Sets an alarm that will call a fiber at the end of it, returns the alarm
    set_alarm(time, fiber) {
        return _alarms.add(Alarm.new(time, fiber))
    }

    process_physics(level) {
        if (is_dead) {
            return
        }

        // Facing
        if (velocity_x > 0) {
            _facing_x = 1
        } else if (velocity_x < 0) {
            _facing_x = -1
        }
        _moving_x = velocity_x.sign
        _moving_y = velocity_y.sign

        var new_x = x + (velocity_x * Engine.delta)
        if (!level.tileset.collision(hitbox, new_x, y)) {
            x = new_x
        }

        var new_y = y + (velocity_y * Engine.delta)
        if (!level.tileset.collision(hitbox, x, new_y)) {
            y = new_y
        }
    }

    is_dead { _has_died }

    die() {
        if (is_invincible || is_dead) {
            return
        }
        if (_death_timer <= 0) {
            _death_timer = (sprite_set.die.frame_count) * sprite_set.die.delay
            sprite_set.die.frame = 0
            _has_died = true
            Save.score = Save.score + score_value
        }
    }

    melee_attack(level, delay_frames) {
        if (is_dead) {
            return false
        }
        if (_attack_timer <= 0) {
            var f = Fiber.new {
                if (!is_dead) {
                    _ranged_attack = false
                    _melee_attack = Attack.create_attack(level, x, y, this, 0, 0, 0, _melee_attack_texture, (sprite_set.attack.frame_count - delay_frames) * sprite_set.attack.delay, _team)
                    _attack_timer = (sprite_set.attack.frame_count - delay_frames) * sprite_set.attack.delay
                }
            }
            _sprite_timer = sprite_set.attack.frame_count * sprite_set.attack.delay
            _sprite_set.attack.frame = 0
            if (delay_frames > 0) {
                set_alarm(delay_frames * sprite_set.attack.delay, f)
            } else {
                f.call()
            }
            return true
        }
        return false
    }

    melee_attack(level) {
        return melee_attack(level, 0)
    }

    // Meant to be overridden, returns true if successful attack so user can spawn attack entity
    ranged_attack(level) {
        if (is_dead) {
            return false
        }
        if (_attack_timer <= 0) {
            _ranged_attack = true
            _attack_timer = sprite_set.ranged_attack.frame_count * sprite_set.ranged_attack.delay
            _sprite_timer = _attack_timer
            _sprite_set.ranged_attack.frame = 0
            return true
        }
        return false
    }

    // Triggers when an attack from the opposite team hits this character
    on_hit(level, attack) {
        if (is_dead) {
            return
        }
        level.pause(Constants.HIT_PAUSE)
        Audio.play(Assets.aud_enemyhit, false, Save.volume, Save.volume)
        die()
        // Spawn the knickknack if this entity has it
        if (_has_knickknack) {
            var knickknack = level.add_entity(Knickknack)
            knickknack.x = x
            knickknack.y = y
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            velocity_x = 0
            velocity_y = 0
            _attack_timer = _attack_timer - Engine.delta
            _sprite_timer = _sprite_timer - Engine.delta

            // Alarms
            for (alarm in _alarms) {
                if (alarm.update()) {
                    _alarms.remove(alarm)
                }
            }

            // Getting hit
            for (attack in level.get_entities(Attack)) {
                if (attack.team != Constants.TEAM_NONE && attack.team != _team) {
                    if (colliding(attack)) {
                        on_hit(level, attack)
                        attack.kill()
                        level.remove_entity(attack)
                    }
                }
            }

            // Death
            if (_death_timer > 0) {
                _death_timer = _death_timer - Engine.delta
                if (_death_timer <= 0) {
                    level.remove_entity(this)
                }
            }

            // Alternator
            _alternator_time = _alternator_time + Engine.delta
            if (_alternator_time > Constants.ALTERNATOR_TIME) {
                _alternator_time = _alternator_time % Constants.ALTERNATOR_TIME
                _alternator = !_alternator
            }

            // Update melee attack entity
            if (_melee_attack != null && _melee_attack.is_gone) {
                _melee_attack = null
            }
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
        // Animations
        if (is_dead) {
            if (level.is_paused) {
                Renderer.colour_mod = [0, 0, 0, 1]
            }
            if (sprite_set.die.frame == sprite_set.die.frame_count - 1) {
                Renderer.draw_sprite(sprite_set.die, sprite_set.die.frame, x, y)
            } else {
                draw_sprite(sprite_set.die, x, y, level.is_paused)
            }
            Renderer.colour_mod = [1, 1, 1, 1]
        } else if (sprite_set.die.frame != sprite_set.die.frame_count - 1) {
            if (is_invincible && _alternator && !_dont_flicker) {
                Renderer.colour_mod = [0, 0, 0, 0]
            }

            // Draw knickknack highlight
            if (_has_knickknack) {
                draw_sprite(Assets.spr_telegraph, x, y, level.is_paused)
            }

            if (_sprite_override != null) {
                _sprite_override.scale_x = _facing_x
                draw_sprite(_sprite_override, x, y, level.is_paused)
            } else if (_sprite_timer > 0) {
                (_ranged_attack ? sprite_set.ranged_attack : sprite_set.attack).scale_x = _facing_x
                draw_sprite(_ranged_attack ? sprite_set.ranged_attack : sprite_set.attack, x, y, level.is_paused)
            } else if (velocity_x == 0 && velocity_y == 0) {
                sprite_set.idle.scale_x = _facing_x
                draw_sprite(sprite_set.idle, x, y, level.is_paused)
            } else {
                sprite_set.walk.scale_x = _facing_x
                draw_sprite(sprite_set.walk, x, y, level.is_paused)
            }
            if (sprite_effect != null) {
                draw_sprite(sprite_effect, x - 16, y - 16, level.is_paused)
            }

            Renderer.colour_mod = [1, 1, 1, 1]
        }
    }
}
