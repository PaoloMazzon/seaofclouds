import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "BlueSlime" for BlueSlime
import "Attack" for Attack
import "Save" for Save

class ThrowingAxe is Entity {
    construct new() {
        super()
        _x_speed = 0
        _y_speed = 0
        _being_thrown = true
        _attack
    }

    x_speed { _x_speed }
    x_speed=(s) { _x_speed = s }
    y_speed { _y_speed }
    y_speed=(s) { _y_speed = s }
    attack { _attack }
    attack=(s) { _attack = s }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_throwingaxe
        sprite.origin_x = sprite.width / 2
        sprite.origin_y = sprite.height / 2
        Assets.spr_floatingaxe.origin_x = sprite.width / 2
        Assets.spr_floatingaxe.origin_y = sprite.height / 2
        hitbox = Hitbox.new_rectangle(sprite.width, sprite.height)
        hitbox.x_offset = -sprite.origin_x
        hitbox.y_offset = -sprite.origin_y
        Audio.play(Assets.aud_playerthrow, false, Save.volume, Save.volume)
    }

    update(level) {
        if (_being_thrown) {
            // Decelerate
            _x_speed = _x_speed - (_x_speed.sign * (Constants.THROWING_AXE_DECELERATION * Engine.delta))
            _y_speed = _y_speed - (_y_speed.sign * (Constants.THROWING_AXE_DECELERATION * Engine.delta))
            x = x + _x_speed * Engine.delta
            y = y + _y_speed * Engine.delta

            // Turn into an item if slow enough or hit a wall
            if (level.tileset.collision(hitbox, x, y) || (_x_speed.pow(2) + _y_speed.pow(2)).sqrt < 30 || _attack.is_gone) {
                _being_thrown = false
                Audio.play(Assets.aud_axeland, false, Save.volume, Save.volume)
                level.shake_screen(Constants.WEAPON_HIT_SHAKE, 0.5)
                level.add_particles(Assets.tex_dirtparticle, x, y, 0, Num.tau, 15, 1, Num.tau, 8)
                level.add_particles(Assets.tex_brokengroundparticle, x, y + 3, 0, 0, 1, 1, 0, 1)
                if (!attack.is_gone) {
                    level.remove_entity(attack)
                }
            }
        } else {
            sprite = Assets.spr_floatingaxe

            if (colliding(level.player)) {
                level.remove_entity(this)
                Audio.play(Assets.aud_pickupaxe, false, Save.volume, Save.volume)
                level.player.return_axe()
            }
        }
    }
}

class Player is Character {
    construct new() {
        super()
        _parry_available = true
        _in_parry = false
        _parry_alarm = null
        _has_axe = true
        _post_death = 0
    }

    return_axe() {
        _has_axe = true
    }

    on_hit(level, attack) {
        if (is_invincible) {
            return
        }
        if (_in_parry) {
            // Skill check
            var f = Fiber.new { |passed|
                if (!passed) {
                    die()
                    Audio.play(Assets.aud_playerdie, false, Save.volume, Save.volume)
                } else {
                    make_invincible(Constants.PLAYER_PARRY_IFRAMES)
                    if (attack.tied_entity == null) {
                        var angle = Math.point_angle(x, y, attack.x, attack.y)
                        level.add_particles(attack.texture, x, y, angle, 0.2, 40, 1, 20, 1)
                        var f = Fiber.new {
                            Audio.play(Assets.aud_parry, false, Save.volume, Save.volume)
                        }
                        set_alarm(0.001, f)
                    }
                }
            }
            level.skill_check(Constants.SKILL_CHECK_EASY, f)

            // Player parry cooldown
            _parry_available = false
            var f2 = Fiber.new { |passed|
                _parry_available = true
                _parry_alarm = null
            }
            _parry_alarm = set_alarm(Constants.PLAYER_PARRY_COOLDOWN, f2)
        } else {
            die()
            Audio.play(Assets.aud_failedskillcheck, false, Save.volume, Save.volume)
            Audio.play(Assets.aud_playerdie, false, Save.volume, Save.volume)
        }
    }

    // Wave function for the death camera you died thing
    death_wave(time) {
        return time > 25 ? 0 : (2.7182818).pow(-0.2 * (time - 3.7202)) * (3 * (time - 3.7202)).sin
    }

    // Draws the player ui, called by level
    draw_ui(level) {
        var icon_width = Assets.spr_parryicon.width
        var icon_height = Assets.spr_parryicon.height
        var control_width = Assets.spr_gamepadcontrols.width
        var control_height = Assets.spr_gamepadcontrols.height
        var spr_controls = Controls.on_gamepad ? Assets.spr_gamepadcontrols : Assets.spr_keyboardcontrols

        // Find position of everything
        var start_x = icon_width * Save.ui_scale
        var start_y = Renderer.window_height - ((icon_height * Save.ui_scale * 2) + (control_height * Save.ui_scale * 0.5))
        var move_x = (icon_width * Save.ui_scale * 1.2)
        var control_offset_x = (icon_width * Save.ui_scale * 0.5) - (control_width * Save.ui_scale * 0.5)
        var control_offset_y = (icon_height * Save.ui_scale) - (Save.ui_scale * 2)
        var sword_icon_pos_x = start_x
        var sword_icon_pos_y = start_y
        var parry_icon_pos_x = start_x + move_x
        var parry_icon_pos_y = start_y
        var axe_icon_pos_x = start_x + move_x + move_x
        var axe_icon_pos_y = start_y
        var parry_frame = _in_parry ? 0 : (_parry_alarm != null ? (_parry_alarm.get_normalized_time() * 8).round : 8)

        // Draw the UI
        Renderer.draw_sprite(Assets.spr_swordicon, is_attacking ? 1 : 0, sword_icon_pos_x, sword_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_ATTACK, sword_icon_pos_x + control_offset_x, sword_icon_pos_y + control_offset_y)
        Renderer.draw_sprite(Assets.spr_parryicon, parry_frame, parry_icon_pos_x, parry_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_PARRY, parry_icon_pos_x + control_offset_x, parry_icon_pos_y + control_offset_y)
        Renderer.draw_sprite(Assets.spr_axeicon, _has_axe ? 1 : 0, axe_icon_pos_x, axe_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_THROW, axe_icon_pos_x + control_offset_x, axe_icon_pos_y + control_offset_y)

        // Post death screen
        if (_post_death >= 1.5) {
            var draw_x = (Renderer.window_width / 2) - (Assets.tex_youdied.width * Save.ui_scale * 0.5)
            var draw_y = (Renderer.window_height * 0.2) - (Assets.tex_youdied.height * Save.ui_scale * 0.5) + (death_wave(10 * (_post_death - 1.5)) * Assets.tex_youdied.height * Save.ui_scale)
            var c_x = draw_x + (165 * Save.ui_scale)
            var c_y = draw_y + (81 * Save.ui_scale)
            Renderer.draw_texture(Assets.tex_youdied, draw_x, draw_y, Save.ui_scale, Save.ui_scale, 0, 0, 0)
            Renderer.draw_sprite(spr_controls, Constants.CONTROL_RESTART, c_x, c_y)
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.PlayerSpriteSet
        team = Constants.TEAM_PLAYER
    }

    death_camera(level) {
        if (!is_dead) {
            return
        }
        _post_death = _post_death + Engine.delta

        if (_post_death >= 3) {
            var entities = level.get_entities(Character)
            var e = this
            for (entity in entities) {
                if (entity != this) {
                    e = entity
                }
            }
            level.set_focal_point(e.x + (Controls.movement_x * 30), e.y + (Controls.movement_y * 30), 1.5)
        } else {
            level.set_focal_point(x, y, 1.5)
        }
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            velocity_x = Controls.movement_x * Constants.PLAYER_SPEED
            velocity_y = Controls.movement_y * Constants.PLAYER_SPEED
            if (_in_parry) {
                velocity_x = velocity_x * Constants.PLAYER_PARRY_MOVEMENT_MODIFIER
                velocity_y = velocity_y * Constants.PLAYER_PARRY_MOVEMENT_MODIFIER
            }
            process_physics(level)

            // Attack
            if (Controls.attack && !_in_parry && melee_attack(level)) {
                var f = Fiber.new {
                    level.shake_screen(Constants.WEAPON_HIT_SHAKE, 0.5)
                    level.add_particles(Assets.tex_dirtparticle, x + (8 * facing), y, 0, Num.tau, 15, 1, Num.tau, 8)
                    level.add_particles(Assets.tex_brokengroundparticle, x + (6 * facing), y + 3, 0, 0, 1, 1, 0, 1)
                }
                set_alarm(sprite_set.attack.delay * 3, f)
                Audio.play(Assets.aud_playerattack, false, Save.volume, Save.volume)
            }
            
            // Throw
            if (Controls.throw_axe && _has_axe && !_in_parry && !is_attacking && ranged_attack(level)) {
                var f = Fiber.new {
                    var axe = level.add_entity(ThrowingAxe)
                    var multiplier = 1
                    var x_dir = moving_x == 0 && moving_y == 0 ? facing : moving_x
                    axe.x = x + facing * 4
                    axe.y = y - 4
                    if (x_dir != 0 && moving_y != 0) {
                        multiplier = 2.sqrt / 2
                    }
                    axe.x_speed = x_dir * Constants.THROWING_AXE_SPEED * multiplier
                    axe.y_speed = moving_y * Constants.THROWING_AXE_SPEED * multiplier
                    axe.attack = Attack.create_attack(level, axe.x, axe.y, axe, 0, 0, 0, Assets.tex_attack, (Constants.THROWING_AXE_SPEED / Constants.THROWING_AXE_DECELERATION).sqrt, Constants.TEAM_PLAYER)
                }
                _has_axe = false
                set_alarm(sprite_set.ranged_attack.delay * 11, f)
            }

            // Parrying
            if (Controls.parry && !is_attacking && _parry_available) {
                if (sprite_override == null) {
                    sprite_override = Assets.spr_player_parry
                    Assets.spr_player_parry.frame = 0
                    Audio.play(Assets.aud_parry, false, Save.volume, Save.volume)
                }
                if (Assets.spr_player_parry.frame == 3) {
                    Assets.spr_player_parry.frame = 3
                }
                var f = Fiber.new {
                    _in_parry = true
                }
                set_alarm(0.15, f)
            } else {
                sprite_override = null
                _in_parry = false
            }
        }
        if (!is_dead) {
            // Focus on player
            var zoom_level = level.in_skill_check ? 2 : (_in_parry ? 1.2 : 1)
            level.set_focal_point(x, y, zoom_level)
        }
    }
}