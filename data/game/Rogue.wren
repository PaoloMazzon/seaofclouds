import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Attack" for Attack
import "Save" for Save

class Bomb is Entity {
    construct new() {
        super()
        _exploded = false
        _invisible = false
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_bomb.copy()
        sprite.origin_x = sprite.width / 2
        sprite.origin_y = sprite.height / 2
        _time = 0
        _dest_x = 0
        _dest_y = 0
        _velocity = 0
        _original_distance = 0
        _exploded = false
        _explosion_sprite = Assets.spr_explosion.copy()
        _explosion_sprite.origin_x = _explosion_sprite.width / 2
        _explosion_sprite.origin_y = _explosion_sprite.height / 2
    }

    invisible=(s) { _invisible = s }
    original_distance=(s) { _original_distance = s }
    time { _time }
    time=(s) { _time = s }
    dest_x { _dest_x }
    dest_x=(s) { _dest_x = s }
    dest_y { _dest_y }
    dest_y=(s) { _dest_y = s }
    velocity { _velocity }
    velocity=(s) { _velocity = s }

    static throw_bomb(level, x, y, dest_x, dest_y, velocity, time) {
        var e = level.add_entity(Bomb)
        e.x = x
        e.y = y
        e.time = time
        e.dest_x = dest_x
        e.dest_y = dest_y
        e.velocity = velocity
        e.original_distance = Math.point_distance(x, y, dest_x, dest_y)
        return e
    }

    static throw_bomb(level, x, y, dest_x, dest_y, velocity, time, invisible) {
        var e = throw_bomb(level, x, y, dest_x, dest_y, velocity, time)
        e.invisible = true
        return e
    }

    speed_curve(percent) {
        return 1 - (percent - 1).pow(2)
    }

    update(level) {
        super.update(level)
        if (level.is_paused) {
            return
        }

        _time = _time - Engine.delta
        if (_time <= 0) {
            if (!_exploded) {
                Audio.play(Assets.aud_explosion, false, Save.volume, Save.volume)
                level.shake_screen(0.2)
            }
            _exploded = true

            // Spawn explosion
            sprite = _explosion_sprite
            Attack.create_attack(level, x, y, this, 0, 0, 0, Assets.tex_explosionhitbox, _explosion_sprite.delay * _explosion_sprite.frame_count, Constants.TEAM_ENEMIES)
            if (_time <= -_explosion_sprite.delay * _explosion_sprite.frame_count) {
                level.remove_entity(this)
            }
        } else {
            // Move
            var v = speed_curve(Math.point_distance(x, y, dest_x, dest_y) / _original_distance) * velocity

            var angle = Math.point_angle(x, y, dest_x, dest_y)
            sprite.rotation = angle
            var vx = v * angle.cos
            var vy = v * angle.sin
            x = x + vx * Engine.delta
            y = y + vy * Engine.delta
        }
    }

    draw(level) {
        if (_invisible) {
            return
        }
        if (level.is_paused) {
            Renderer.draw_sprite(sprite, sprite.frame, x, y)
        } else {
            Renderer.draw_sprite(sprite, x, y)
        }
    }
}

class Rogue is Character {
    static STATE_WANDER { 0 }
    static STATE_CIRCLE_PLAYER { 1 }
    static STATE_CHARGE { 2 }
    static STATE_CHASE { 3 } // rogue is a state machine
    static STATE_BOMB { 4 }

    construct new() { 
        super() 
        _direction = 0
        _time = 0
        _max_time = 0
        team = Constants.TEAM_ENEMIES
        _player_last_known_x = 0
        _player_last_known_y = 0
        _state = Rogue.STATE_WANDER
        _shoot_cooldown = 0
        _circle_time = 0
        _bowshot_sound = null
        score_value = Constants.ROGUE_SCORE_VALUE
        _circling_angle = 0 // for circling player
        _fighter_charge_timer = 0
        _thrown_bomb = false
        extra_lives = extra_lives + Constants.ROGUE_EXTRA_LIVES
    }

    ranged_attack(level) {
        if (super.ranged_attack(level)) {
            Bomb.throw_bomb(level, x, y, level.player.x, level.player.y, 130, Constants.ROGUE_BOMB_DETONATION_TIMER)
            return true
        }
        return false
    }

    die() {
        super.die()
        Bomb.throw_bomb(_level, x, y, 0, 0, 0, Constants.ROGUE_BOMB_DETONATION_TIMER, true)
        // _bowshot_sound.stop() - might cause crashes not sure
    }

    on_hit(level, attack) {
        super.on_hit(level, attack)
        level.add_particles(Assets.tex_humanparticle, x, y, Math.point_angle(attack.x, attack.y, x, y), Num.pi * 0.3, 40, 1, Num.pi, 10)
    }

    // Picks a new direction to start moving in for wander phase
    start_direction() {
        _direction = _rng.float(Num.tau)
        _time = _rng.float(1.5, 3.5)
        _walk = true
        _max_time = _time
    }

    // Same as above but idle instead of walking around
    idle() {
        _time = _rng.float(1.5, 3.5)
        _walk = false
        _max_time = _time
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.RogueSpriteSet
        _rng = level.rng
        _circling_angle = level.rng.float(Num.tau)
        start_direction()
        _circling_sign = 1
        _circling_switch_time = level.rng.float(1)
        melee_attack_texture = Assets.tex_fighterattack
        _bomb_timer = level.rng.float(Constants.ROGUE_BOMB_TIMER)
        _level = level
    }

    enter_circling(level) {
        _state = Rogue.STATE_CIRCLE_PLAYER
        _circle_time = level.rng.float(Constants.ROGUE_MIN_CIRCLE_TIME, Constants.ROGUE_MAX_CIRCLE_TIME)
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            // Process circling counters
            _circling_angle = _circling_angle + (Engine.delta * _circling_sign)
            _circling_switch_time = _circling_switch_time + Engine.delta
            if (_circling_switch_time >= 1) {
                if (level.rng.int(2) == 1) {
                    _circling_sign = -_circling_sign
                }
                _circling_switch_time = 0
            }

            // Always on guard for the player
            var dist = Math.point_distance(level.player.x, level.player.y, x, y)
            if (dist < Constants.ROGUE_AGGRO_RANGE && (_state == Rogue.STATE_WANDER || _state == Rogue.STATE_CHASE)) {
                enter_circling(level)
            }

            // If the player is dead don't circle them
            if (level.player.is_dead) {
                _state = Rogue.STATE_WANDER
            }

            if (_state == Rogue.STATE_WANDER) {
                _time = _time - Engine.delta
                if (_time <= 0) {
                    if (!_walk) {
                        start_direction()
                    } else {
                        idle()
                    }
                }
                hidden = true
                if (_walk) {
                    velocity_x = Constants.ROGUE_WALK_SPEED * _direction.cos
                    velocity_y = Constants.ROGUE_WALK_SPEED * _direction.sin
                }
            } else if (_state == Rogue.STATE_CIRCLE_PLAYER || _state == Rogue.STATE_CHARGE || _state == Rogue.STATE_BOMB) {
                // If they go out of range switch to chase
                if (dist >= Constants.ROGUE_AGGRO_RANGE_IN_FIGHT) {
                    _state = Rogue.STATE_CHASE
                    _time = _rng.float(Constants.ROGUE_SEARCH_TIME_MIN, Constants.ROGUE_SEARCH_TIME_MAX)
                }

                // Unhide
                hidden = false

                // Record last known position
                _player_last_known_x = level.player.x
                _player_last_known_y = level.player.y

                // Reduce bomb timer
                _bomb_timer = _bomb_timer - Engine.delta

                if (_state == Rogue.STATE_CHARGE) {
                    // Charge the player while attacking
                    _fighter_charge_timer = _fighter_charge_timer - Engine.delta
                    if (_fighter_charge_timer <= 0) {
                        enter_circling(level)
                    }

                    if (dist > 5) {
                        var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                        velocity_x = Constants.ROGUE_CHARGE_SPEED * angle.cos
                        velocity_y = Constants.ROGUE_CHARGE_SPEED * angle.sin
                    }
                } else if (_state == Rogue.STATE_CIRCLE_PLAYER) {
                    // Move in a circle around the player
                    _circle_time = _circle_time - Engine.delta
                    var target_x = level.player.x + (Constants.ROGUE_CIRCLE_DISTANCE * _circling_angle.cos)
                    var target_y = level.player.y + (Constants.ROGUE_CIRCLE_DISTANCE * _circling_angle.sin)
                    if (Math.point_distance(x, y, target_x, target_y) > 5) {
                        var angle = Math.point_angle(x, y, target_x, target_y)
                        velocity_x = Constants.ROGUE_RUN_SPEED * angle.cos
                        velocity_y = Constants.ROGUE_RUN_SPEED * angle.sin
                    }

                    // Chance they throw a bomb if the bomb timer is up, otherwise charge
                    if (_circle_time <= 0 && !is_dead) {
                        if (_bomb_timer < 0 && level.rng.float(0, 1) <= Constants.ROGUE_BOMB_CHANCE) {
                            _state = Rogue.STATE_BOMB
                        } else {
                            _state = Rogue.STATE_CHARGE
                            _fighter_charge_timer = Constants.ROGUE_CHARGE_TIME
                            melee_attack(level, 6)
                            Audio.play(Assets.aud_fighterattack, false, Save.volume, Save.volume)
                        }
                    }
                } else if (_state == Rogue.STATE_BOMB) {
                    // Throw the bomb and set an alarm to switch back to circling
                    if (!_thrown_bomb && ranged_attack(level)) {
                        Audio.play(Assets.aud_throwbomb, false, Save.volume, Save.volume)
                        sprite_set.ranged_attack.frame = 0
                        var f = Fiber.new {
                            _thrown_bomb = false
                            _state = Rogue.STATE_CIRCLE_PLAYER
                        }
                        set_alarm(sprite_set.ranged_attack.delay * sprite_set.ranged_attack.frame_count, f)
                    }

                    _thrown_bomb = true
                    _bomb_timer = Constants.ROGUE_BOMB_TIMER
                }
            } else if (_state == Rogue.STATE_CHASE) {
                // Run towards last known locations
                if (Math.point_distance(_player_last_known_x, _player_last_known_y, x, y) > 5) {
                    var angle = Math.point_angle(x, y, _player_last_known_x, _player_last_known_y)
                    velocity_x = Constants.ROGUE_RUN_SPEED * angle.cos
                    velocity_y = Constants.ROGUE_RUN_SPEED * angle.sin
                }
                hidden = false

                // Switch back to wander if search over
                _time = _time - Engine.delta
                if (_time <= 0) {
                    _state = Rogue.STATE_WANDER
                    start_direction()
                }
            }
            process_physics(level)
        }
    }
}