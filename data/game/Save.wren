
class Items {
    static ITEM_COUNT { 4 }
    static DASH_INDEX { 0 }
    static BOOTS_INDEX { 1 }
    static MAGNET_INDEX { 2 }
    static WHETSTONE_INDEX { 3 }
    construct new() {
        _items = []
        for (i in 1..Items.ITEM_COUNT) {
            _items.add(0)
        }
    }

    construct new(list) {
        _items = list
    }

    internal_list { _items }

    static item_text(id) {
        var texts = [
            "Dash a short distance",
            "Run faster",
            "Axe returns",
            "Shorter parry cooldown"
        ]
        return texts[id]
    }

    // Removes all items
    restart() {
        for (i in 0.._items.count - 1) {
            _items[i] = 0
        }
    }

    remove_item(id) {
        _items[id] = _items[id] > 0 ? _items[id] - 1 : 0
    }

    has_item(id) {
        return _items[id] > 0
    }

    item_count(id) {
        return _items[id]
    }

    [id] {
        return item_count(id)
    }

    give_item(id) {
        _items[id] = _items[id] + 1
    }
}

class SaveImpl {
    construct new() {
        _volume = 1
        _ui_scale = 1
        _items = Items.new()
        _stage = 1
        _score = 0
        _shake_intensity = 3
        _shake_modifier = 1
        _fullscreen = false
    }

    // Called at the start of the game
    load() {

    }

    // Should be called at the end of runs
    save() {

    }

    // Called when the game is restarted
    restart() {
        _items.restart()
        _stage = 1
        _score = 0
    }

    fullscreen=(s) { _fullscreen = s }
    fullscreen { _fullscreen}
    shake_modifier=(s) { _shake_modifier = s }
    shake_modifier { _shake_modifier }
    shake_intensity { _shake_intensity * _shake_modifier }
    items { _items }
    volume { _volume }
    volume=(s) { _volume = s }
    score { _score }
    score=(s) { _score = s }
    stage { _stage }
    stage=(s) { _stage = s }
    ui_scale { _ui_scale }
    ui_scale=(s) { 
        _ui_scale = s
        Assets.spr_gamepadcontrols.scale_x = _ui_scale
        Assets.spr_gamepadcontrols.scale_y = _ui_scale
        Assets.spr_keyboardcontrols.scale_x = _ui_scale
        Assets.spr_keyboardcontrols.scale_y = _ui_scale
        Assets.spr_parryicon.scale_x = _ui_scale
        Assets.spr_parryicon.scale_y = _ui_scale
        Assets.spr_axeicon.scale_x = _ui_scale
        Assets.spr_axeicon.scale_y = _ui_scale
        Assets.spr_swordicon.scale_x = _ui_scale
        Assets.spr_swordicon.scale_y = _ui_scale
        Assets.spr_dashicon.scale_x = _ui_scale
        Assets.spr_dashicon.scale_y = _ui_scale
        Assets.spr_itemdisplay.scale_x = _ui_scale
        Assets.spr_itemdisplay.scale_y = _ui_scale
        Assets.spr_items.scale_x = _ui_scale
        Assets.spr_items.scale_y = _ui_scale
        Assets.spr_digits.scale_x = _ui_scale
        Assets.spr_digits.scale_y = _ui_scale
    }
}

var Save = SaveImpl.new()
Save.load()