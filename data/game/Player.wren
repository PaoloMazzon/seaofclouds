import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "BlueSlime" for BlueSlime
import "Save" for Save

class Player is Character {
    construct new() {
        super()
        _parry_available = true
        _in_parry = false
        _parry_alarm = null
        _has_axe = true
        _post_death = 0
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
        var parry_frame = _parry_alarm != null ? (_parry_alarm.get_normalized_time() * 8).round : 8

        // Draw the UI
        Renderer.draw_sprite(Assets.spr_swordicon, is_attacking ? 1 : 0, sword_icon_pos_x, sword_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_ATTACK, sword_icon_pos_x + control_offset_x, sword_icon_pos_y + control_offset_y)
        Renderer.draw_sprite(Assets.spr_parryicon, parry_frame, parry_icon_pos_x, parry_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_PARRY, parry_icon_pos_x + control_offset_x, parry_icon_pos_y + control_offset_y)
        Renderer.draw_sprite(Assets.spr_axeicon, _has_axe ? 1 : 0, axe_icon_pos_x, axe_icon_pos_y)
        Renderer.draw_sprite(spr_controls, Constants.CONTROL_THROW, axe_icon_pos_x + control_offset_x, axe_icon_pos_y + control_offset_y)
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

            // Parrying
            if (Controls.parry && _parry_available) {
                if (sprite_override == null) {
                    sprite_override = Assets.spr_player_parry
                    Assets.spr_player_parry.frame = 0
                    Audio.play(Assets.aud_parry, false, Save.volume, Save.volume)
                }
                if (Assets.spr_player_parry.frame == 3) {
                    Assets.spr_player_parry.frame = 3
                }
                _in_parry = true
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