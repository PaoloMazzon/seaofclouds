import "Constants" for Constants
import "Character" for Character, SpriteSet
import "Controls" for Controls
import "Save" for Save, Items
import "FloatingText" for FloatingText

class Chest is Entity {
    construct new() {
        super()
        sprite = Assets.spr_chest
        sprite.origin_x = sprite.width / 2
        sprite.origin_y = sprite.height / 2
        _timer = 0
        _chest_open = false
        _chest_open_delay = 2
        _item_movement = 2
        _item_oscillate = 3
        _given_item = false
        _item_give_delay = 1
        _item = 0
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _item = level.rng.sample([1, 2, 3, 5])
        if (level.rng.float() < Constants.RARE_ITEM_CHANCE) {
            _item = level.rng.sample([0, 4])
        }
        
        _create_timer = 1
    }
    
    jump(time) {
        return (-4 * (time - 0.5).pow(2)) + 1
    }

    update(level) {
        super.update(level)
        if (level.is_paused) {
            return
        }
        _create_timer = _create_timer - Engine.delta

        if (_create_timer <= 0 && !_chest_open && Controls.confirm && Math.point_distance(x, y, level.player.x, level.player.y) < 10) {
            _chest_open = true
            _open_this_frame = true
            level.chest_open(_item_movement + _item_oscillate + _chest_open_delay)
            if (_item == Items.PIZZA_INDEX) {
                level.player.extra_lives = level.player.extra_lives + 1
            }
            Audio.play(Assets.aud_chestopen, false, Save.volume, Save.volume)
        }
    }

    draw(level) {
        var y_mod = 0
        if (_create_timer > 0) {
            y_mod = -15 * jump(_create_timer)
        }
        Renderer.draw_sprite(sprite, _chest_open ? 1 : 0, x, y + y_mod)

        if (_create_timer <= 0) {
            Assets.spr_gamepadcontrols.scale_x = 1/3
            Assets.spr_gamepadcontrols.scale_y = 1/3
            Assets.spr_keyboardcontrols.scale_x = 1/3
            Assets.spr_keyboardcontrols.scale_y = 1/3
            Assets.spr_items.scale_x = 1/3
            Assets.spr_items.scale_y = 1/3
            if (!_chest_open && Math.point_distance(x, y, level.player.x, level.player.y) < 10) {
                var spr_controls = Controls.on_gamepad ? Assets.spr_gamepadcontrols : Assets.spr_keyboardcontrols
                Renderer.draw_sprite(spr_controls, Constants.CONTROL_CONFIRM, x - (Assets.spr_keyboardcontrols.width / 6), y + 9 - (Assets.spr_keyboardcontrols.height / 6))
            } else if (_chest_open) {
                _timer = _timer + Engine.delta
                if (level.in_chest && Controls.confirm && !_open_this_frame) {
                    _timer = _timer + _item_movement + _item_oscillate + _chest_open_delay
                    level.unpause()
                }
                _open_this_frame = false

                if (_timer < _chest_open_delay) {
                    var percent = _timer / _chest_open_delay
                    level.set_focal_point(x, y, 2)
                } else if (_timer >= _chest_open_delay && _timer < _chest_open_delay + _item_movement) {
                    var percent = (_timer - _chest_open_delay) / _item_movement
                    level.set_focal_point(x, y, 2)
                    Renderer.colour_mod = [1, 1, 1, percent]
                    Renderer.draw_sprite(Assets.spr_items, _item, x - 4, y - 4 - (4 * percent))
                    Renderer.colour_mod = [1, 1, 1, 1]
                } else if (_timer >= _item_movement + _chest_open_delay && !_given_item) {
                    var percent = (_timer - _chest_open_delay - _item_movement) / _item_oscillate
                    if (_timer < _item_movement + _item_oscillate + _chest_open_delay) {
                        level.set_focal_point(x, y, 2)
                    }
                    Renderer.draw_sprite(Assets.spr_items, _item, x - 4, y - 8 + Engine.time.sin)

                    if (!_given_item && _timer >= _item_give_delay + _item_movement + _item_oscillate + _chest_open_delay && !level.player.is_dead) {
                        _given_item = true
                        Save.items.give_item(_item)
                        Audio.play(Assets.aud_pickup, false, Save.volume, Save.volume)
                        FloatingText.create_floating_text(level, x, y, Items.item_text(_item))
                    }
                }
            }

            Assets.spr_gamepadcontrols.scale_x = Save.ui_scale
            Assets.spr_gamepadcontrols.scale_y = Save.ui_scale
            Assets.spr_keyboardcontrols.scale_x = Save.ui_scale
            Assets.spr_keyboardcontrols.scale_y = Save.ui_scale
            Assets.spr_items.scale_x = Save.ui_scale
            Assets.spr_items.scale_y = Save.ui_scale
        }
    }
}