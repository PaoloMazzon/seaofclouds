import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "BlueSlime" for BlueSlime
import "Attack" for Attack
import "Save" for Save, Items
import "Chest" for Chest

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

            // Move if the player has a magnet
            var move_speed = Constants.ITEMS_MAGNET_AXE_SPEED * Save.items[Items.MAGNET_INDEX]
            var angle = Math.point_angle(x, y, level.player.x, level.player.y - 2)
            x = x + (move_speed * Engine.delta * angle.cos)
            y = y + (move_speed * Engine.delta * angle.sin)

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
        _dash_duration = 0
        _dash_alarm = null
        _dash_available = true
    }

    return_axe() {
        _has_axe = true
    }

    in_dash { _dash_duration > 0 }

    die() {
        super.die()
        Save.save()
    }

    on_hit(level, attack) {
        if (is_invincible || is_dead) {
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
            var item_multiplier = Save.items.has_item(Items.WHETSTONE_INDEX) ? Constants.ITEMS_WHETSTONE_FACTOR.pow(Save.items[Items.WHETSTONE_INDEX]) : 1
            _parry_alarm = set_alarm(Constants.PLAYER_PARRY_COOLDOWN * item_multiplier, f2)
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
        var sword_icon_pos_x = start_x + move_x
        var sword_icon_pos_y = start_y
        var parry_icon_pos_x = start_x + move_x + move_x
        var parry_icon_pos_y = start_y
        var axe_icon_pos_x = start_x + move_x + move_x + move_x
        var axe_icon_pos_y = start_y
        var dash_icon_pos_x = start_x + move_x + move_x + move_x + move_x
        var dash_icon_pos_y = start_y
        var knickknack_icon_pos_x = start_x - (Save.ui_scale * 8)
        var knickknack_icon_pos_y = start_y - (Save.ui_scale * 6)
        var parry_frame = _in_parry ? 0 : (_parry_alarm != null ? (_parry_alarm.get_normalized_time() * 8).round : 8)
        var dash_frame = _dash_alarm != null ? (_dash_alarm.get_normalized_time() * 8).round : 8
        var top_left = (icon_height * Save.ui_scale)
        var banner_current_x = start_x
        var banner_move_x = Assets.spr_itemdisplay.width * Save.ui_scale
        var item_start_x = (12 * Save.ui_scale)
        var item_start_y = (12 * Save.ui_scale)

        // Draw the UI
        Renderer.draw_sprite(Assets.spr_swordicon, is_attacking ? 1 : 0, sword_icon_pos_x, sword_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_ATTACK, sword_icon_pos_x + control_offset_x, sword_icon_pos_y + control_offset_y)
        Renderer.draw_sprite(Assets.spr_parryicon, parry_frame, parry_icon_pos_x, parry_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_PARRY, parry_icon_pos_x + control_offset_x, parry_icon_pos_y + control_offset_y)
        Renderer.draw_sprite(Assets.spr_axeicon, _has_axe ? 1 : 0, axe_icon_pos_x, axe_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_THROW, axe_icon_pos_x + control_offset_x, axe_icon_pos_y + control_offset_y)
        if (Save.items.has_item(Items.DASH_INDEX)) {
            Renderer.draw_sprite(spr_controls, Constants.CONTROL_CONFIRM, dash_icon_pos_x + control_offset_x, dash_icon_pos_y + control_offset_y)
            Renderer.draw_sprite(Assets.spr_dashicon, dash_frame, dash_icon_pos_x, dash_icon_pos_y)
        }
        Renderer.draw_texture(Assets.tex_knickknackui, knickknack_icon_pos_x, knickknack_icon_pos_y, Save.ui_scale, Save.ui_scale, 0, 0, 0)
        if (level.has_knickknack) {
            Renderer.draw_texture(level.knickknack_textures[level.knickknack_id], knickknack_icon_pos_x + (Save.ui_scale * 3 * 4), knickknack_icon_pos_y + (Save.ui_scale * 3 * 4), Save.ui_scale * 3, Save.ui_scale * 3, 0, 0, 0)
        }

        // Items
        Renderer.draw_sprite(Assets.spr_itemdisplay, 0, banner_current_x, top_left)
        banner_current_x = banner_current_x + banner_move_x
        for (i in 0..Items.ITEM_COUNT - 1) {
            if (Save.items.item_count(i) > 0) {
                for (j in 1..Save.items.item_count(i)) {
                    Renderer.draw_sprite(Assets.spr_itemdisplay, 1, banner_current_x, top_left)
                    Renderer.draw_sprite(Assets.spr_items, i, banner_current_x + item_start_x, top_left + item_start_y)
                    banner_current_x = banner_current_x + banner_move_x
                }
            }
        }
        Renderer.draw_sprite(Assets.spr_itemdisplay, 2, banner_current_x, top_left)

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
            if (!in_dash) {
                var speed = Constants.PLAYER_SPEED + (Save.items[Items.BOOTS_INDEX] * Constants.ITEM_BOOTS_SPEED)
                velocity_x = Controls.movement_x * speed
                velocity_y = Controls.movement_y * speed
                if (_in_parry) {
                    velocity_x = velocity_x * Constants.PLAYER_PARRY_MOVEMENT_MODIFIER
                    velocity_y = velocity_y * Constants.PLAYER_PARRY_MOVEMENT_MODIFIER
                }
            } else {
                var multiplier = 1
                var x_dir = moving_x == 0 && moving_y == 0 ? facing : moving_x
                if (x_dir != 0 && moving_y != 0) {
                    multiplier = 2.sqrt / 2
                }
                var speed = Constants.ITEM_DASH_SPEED + (Save.items[Items.BOOTS_INDEX] * Constants.ITEM_BOOTS_SPEED)
                velocity_x = x_dir * speed * multiplier
                velocity_y = moving_y * speed * multiplier
            }
            process_physics(level)

            // Attack
            if (Controls.attack && !_in_parry && melee_attack(level, 2)) {
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

            // Dash
            if (_dash_available && _dash_duration <= 0 && !is_attacking && !_in_parry && Controls.confirm && Save.items.has_item(Items.DASH_INDEX)) {
                _dash_duration = Constants.ITEM_DASH_DURATION
                _dash_available = false
                make_invincible_no_flicker(Constants.ITEM_DASH_DURATION)
                var f = Fiber.new {
                    _dash_available = true
                    _dash_alarm = null
                }
                var item_multiplier = Save.items[Items.DASH_INDEX] > 1 ? Constants.ITEMS_WHETSTONE_FACTOR.pow(Save.items[Items.DASH_INDEX] - 1) : 1
                _dash_alarm = set_alarm(Constants.PLAYER_PARRY_COOLDOWN * item_multiplier, f)
                Audio.play(Assets.aud_playerdash, false, Save.volume, Save.volume)
            } else {
                _dash_duration = _dash_duration - Engine.delta
            }
            sprite_effect = in_dash ? Assets.spr_sheild : null

            // Debug
            if (Keyboard.key_pressed(Keyboard.KEY_0)) {
                var c = level.add_entity(Chest)
                c.x = x
                c.y = y
            }

            // Leave level icon
            if (Math.point_distance(x, y, level.end_x, level.end_y) < 30) {
                Assets.spr_gamepadcontrols.scale_x = 1/3
                Assets.spr_gamepadcontrols.scale_y = 1/3
                Assets.spr_keyboardcontrols.scale_x = 1/3
                Assets.spr_keyboardcontrols.scale_y = 1/3
                var spr_controls = Controls.on_gamepad ? Assets.spr_gamepadcontrols : Assets.spr_keyboardcontrols
                Renderer.draw_sprite(spr_controls, Constants.CONTROL_CONFIRM, x - (Assets.spr_keyboardcontrols.width / 6), y + 9 - (Assets.spr_keyboardcontrols.height / 6))
                Assets.spr_gamepadcontrols.scale_x = Save.ui_scale
                Assets.spr_gamepadcontrols.scale_y = Save.ui_scale
                Assets.spr_keyboardcontrols.scale_x = Save.ui_scale
                Assets.spr_keyboardcontrols.scale_y = Save.ui_scale

                if (Controls.confirm) {
                    level.next_level()
                }
            }
        }
        if (!is_dead) {
            // Focus on player
            var zoom_level = level.in_skill_check ? 2 : (_in_parry ? 1.2 : 1)
            level.set_focal_point(x, y, zoom_level)
        }
    }
}