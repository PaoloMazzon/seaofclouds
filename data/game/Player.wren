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
    }

    on_hit(level) {
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
            }
            set_alarm(Constants.PLAYER_PARRY_COOLDOWN, f2)
        } else {
            die()
            Audio.play(Assets.aud_playerdie, false, Save.volume, Save.volume)
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.PlayerSpriteSet
        team = Constants.TEAM_PLAYER
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

            // Debug
            if (Keyboard.key_pressed(Keyboard.KEY_O)) {
                on_hit(level)
            }
            if (Keyboard.key_pressed(Keyboard.KEY_L)) {
                var slime = level.add_entity(BlueSlime)
                slime.x = x
                slime.y = y
            }

            // Focus on player
            var zoom_level = level.in_skill_check || Keyboard.key(Keyboard.KEY_C) ? 2 : (_in_parry ? 1.2 : 1)
            level.set_focal_point(x, y, zoom_level)
        }
    }
}