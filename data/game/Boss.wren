import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Attack" for Attack
import "Alien" for Alien
import "Save" for Save
import "FloatingText" for FloatingText

class Boss is Character {
    static STATE_WAIT { 0 }
    static STATE_RUN_N_GUN { 1 }
    static STATE_MELEE { 2 } // boss is a state machine
    static STATE_SPAWN_ALIEN { 3 }

    construct new() { 
        super()
        team = Constants.TEAM_ENEMIES
        _state = Boss.STATE_WAIT
        _bowshot_sound = null
        score_value = Constants.BOSS_SCORE_VALUE
        extra_lives = extra_lives + Constants.BOSS_EXTRA_LIVES
        iframes = Constants.BOSS_IFRAMES
    }

    spawn_alien(level) {
        var new_x = level.rng.float(x - Constants.BOSS_ALIEN_SPAWN_RADIUS, x + Constants.BOSS_ALIEN_SPAWN_RADIUS)
        var new_y = level.rng.float(y - Constants.BOSS_ALIEN_SPAWN_RADIUS, y + Constants.BOSS_ALIEN_SPAWN_RADIUS)
        var e = level.add_entity(Alien)
        e.x = new_x
        e.y = new_y
    }

    ranged_attack(level) {
        if (!level.player.is_dead && super.ranged_attack(level)) {
            sprite_set.ranged_attack.frame = 0
            var f = Fn.new {
                if (!is_dead) {
                    var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                    var s_x = x + (4 * angle.cos)
                    var s_y = y + (4 * angle.sin)
                    Attack.create_attack(level, s_x, s_y, null, angle, Constants.BOSS_BULLET_SPEED * angle.cos, Constants.BOSS_BULLET_SPEED * angle.sin, Assets.tex_bullet, Constants.BOSS_BULLET_LIFETIME, Constants.TEAM_ENEMIES, Constants.SKILL_CHECK_HARD)
                    Attack.create_attack(level, s_x, s_y, null, angle, Constants.BOSS_BULLET_SPEED * angle.cos + 0.4, Constants.BOSS_BULLET_SPEED * angle.sin + 0.4, Assets.tex_bullet, Constants.BOSS_BULLET_LIFETIME, Constants.TEAM_ENEMIES, Constants.SKILL_CHECK_HARD)
                    Attack.create_attack(level, s_x, s_y, null, angle, Constants.BOSS_BULLET_SPEED * angle.cos - 0.4, Constants.BOSS_BULLET_SPEED * angle.sin - 0.4, Assets.tex_bullet, Constants.BOSS_BULLET_LIFETIME, Constants.TEAM_ENEMIES, Constants.SKILL_CHECK_HARD)
                    level.shake_screen(Constants.WEAPON_HIT_SHAKE)
                    Audio.play(Assets.aud_gunshot, false, Save.volume, Save.volume)
                }
            }
            set_alarm(sprite_set.ranged_attack.delay * 7, f)
            set_alarm(sprite_set.ranged_attack.delay * 15, f)
            set_alarm(sprite_set.ranged_attack.delay * 23, f)
        } // 8, 16, 24
    }

    die() {
        super.die()
        Save.beaten_game = true
        _level.stop_music()
        Audio.play(Assets.aud_title, false, Save.volume, Save.volume)
        // _bowshot_sound.stop() - might cause crashes not sure
    }

    on_hit(level, attack) {
        super.on_hit(level, attack)
        level.add_particles(Assets.tex_humanparticle, x, y, Math.point_angle(attack.x, attack.y, x, y), Num.pi * 0.3, 40, 1, Num.pi, 10)
    }

    // Same as above but idle instead of walking around
    idle() {
        _cooldown_time = _rng.float(Constants.BOSS_PHASE_COOLDOWN_TIME_MIN, Constants.BOSS_PHASE_COOLDOWN_TIME_MAX)
        _state = Boss.STATE_WAIT
    }

    idle(modifier) {
        _cooldown_time = _rng.float(Constants.BOSS_PHASE_COOLDOWN_TIME_MIN, Constants.BOSS_PHASE_COOLDOWN_TIME_MAX)
        _cooldown_time = _cooldown_time * modifier
        _state = Boss.STATE_WAIT
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite_set = SpriteSet.BossSpriteSet
        _rng = level.rng
        _shot = false
        idle()
        _attack_timer = 0
        _level = level
        melee_attack_texture = Assets.tex_fighterattack
        hard_melee()
        level.start_boss_cutscene(3)
        FloatingText.create_floating_text(level, x, y, "\"Your journey ends here.\"")
    }

    update(level) {
        super.update(level)

        if (level.boss_cutscene) {
            level.set_focal_point(x, y, 1.3)
        }

        if (!level.is_paused && !level.player.is_dead) {
            if (_state == Boss.STATE_WAIT) {
                _cooldown_time = _cooldown_time - Engine.delta

                // Pick a state to move to
                if (_cooldown_time < 0) {
                    _state = _rng.sample([Boss.STATE_MELEE, Boss.STATE_RUN_N_GUN, Boss.STATE_SPAWN_ALIEN])
                    _shot = false
                    _attack_timer = Constants.BOSS_CHARGE_TIME
                }
            } else if (_state == Boss.STATE_RUN_N_GUN) {
                // Ranged attack once then run towards player within BOSS_MIN_SHOOT_DISTANCE
                if (Math.point_distance(level.player.x, level.player.y, x, y) > Constants.BOSS_MIN_SHOOT_DISTANCE) {
                    var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                    velocity_x = angle.cos * Constants.BOSS_WALK_SPEED
                    velocity_y = angle.sin * Constants.BOSS_WALK_SPEED
                }
                if (!_shot) {
                    _shot = true
                    ranged_attack(level)
                    var f = Fiber.new {
                        idle()
                    }
                    set_alarm(sprite_set.ranged_attack.delay * sprite_set.ranged_attack.frame_count, f)
                }
            } else if (_state == Boss.STATE_SPAWN_ALIEN) {
                // Spawn a random number of aliens around, disp lay a message then go back to idling
                FloatingText.create_floating_text(level, x, y, "\"Come forth!\"")
                var count = _rng.sample(Constants.BOSS_ALIEN_SPAWN_COUNT)
                while (count > 0) {
                    count = count - 1
                    spawn_alien(level)
                }
                Audio.play(Assets.aud_summonaliens, false, Save.volume, Save.volume)
                idle()
            } else if (_state == Boss.STATE_MELEE) {
                // Charge at the player for a set amount of time and melee when close enough
                _attack_timer = _attack_timer - Engine.delta
                if (_attack_timer <= 0) {
                    idle()
                }

                if (Math.point_distance(level.player.x, level.player.y, x, y) > 5) {
                    var angle = Math.point_angle(x, y, level.player.x, level.player.y)
                    velocity_x = angle.cos * Constants.BOSS_CHARGE_SPEED
                    velocity_y = angle.sin * Constants.BOSS_CHARGE_SPEED
                } 
                if (!_shot && !is_attacking && Math.point_distance(level.player.x, level.player.y, x, y) < 10) {
                    melee_attack(level, 4)
                    _shot = true
                    Audio.play(Assets.aud_fighterattack, false, Save.volume, Save.volume)
                    var f = Fiber.new {
                        idle(Constants.BOSS_PHASE_MELEE_MODIFIER)
                    }
                    set_alarm(sprite_set.attack.delay * sprite_set.attack.frame_count, f)
                }
            }
            process_physics(level)
        }
    }
}