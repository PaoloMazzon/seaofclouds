
class Items {
    static ITEM_COUNT { 6 }
    static DASH_INDEX { 0 }
    static BOOTS_INDEX { 1 }
    static MAGNET_INDEX { 2 }
    static WHETSTONE_INDEX { 3 }
    static PIZZA_INDEX { 4 }
    static GLASS_INDEX { 5 }

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
            "Shorter parry cooldown",
            "+1 life",
            "See farther"
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

    set_item(id, count) {
        _items[id] = count
    }

    give_item(id) {
        _items[id] = _items[id] + 1
    }

    copy() {
        var items = Items.new()
        for (index in 0..Items.ITEM_COUNT - 1) {
            items.set_item(index, item_count(index))
        }
        return items
    }

    save_to_string() {
        var s = ""
        for (i in 0..Items.ITEM_COUNT - 1) {
            s = s + item_count(i).toString + ","
        }
        return s.trimEnd(",")
    }

    static load_from_string(string) {
        if (string == "") {
            return Items.new()
        }
        var items = Items.new()
        var parts = string.split(",")
        var index = 0
        for (part in parts) {
            if (index >= Items.ITEM_COUNT) {
                break
            }
            items.set_item(index, Num.fromString(part))
            index = index + 1
        }
        return items
    }
}

class SaveImpl {
    construct new() {
        _volume = 1
        _ui_scale = 2
        _crt_effect = true
        _items = Items.new()
        _stage = 4
        _score = 0
        _highscore = 0
        _beaten_game = false
        _shake_intensity = 3
        _shake_modifier = 1
        _fullscreen = false
        _best_run_parries = 0
        _best_run_kills = 0
        _best_run_items = ""
        _best_run_highest_stage = 0
        _best_run_props_destroyed = 0
        _best_run_npcs_killed = 0
        _best_run_axes_thrown = 0
        _total_parries = 0
        _total_kills = 0
        _total_highest_stage = 0
        _total_props_destroyed = 0
        _total_npcs_killed = 0
        _total_axes_thrown = 0
        _total_runs = 0
        _oops_all_wizards = false
    }

    // Called at the start of the game
    load() {
        var ini = INI.open("save.ini")
        _volume = ini.get_num("game", "volume", 1)
        _ui_scale = ini.get_num("game", "ui_scale", 2)
        _crt_effect = ini.get_bool("game", "crt_effect", true)
        _highscore = ini.get_num("game", "highscore", 0)
        _best_run_parries = ini.get_num("game", "best_run_parries", 0)
        _beaten_game = ini.get_bool("game", "beaten_game", false)
        _best_run_kills = ini.get_num("game", "best_run_kills", 0)
        _best_run_items = Items.load_from_string(ini.get_string("game", "best_run_items", ""))
        _best_run_highest_stage = ini.get_num("game", "best_run_highest_stage", 0)
        _best_run_props_destroyed = ini.get_num("game", "best_run_props_destroyed", 0)
        _best_run_npcs_killed = ini.get_num("game", "best_run_npcs_killed", 0)
        _best_run_axes_thrown = ini.get_num("game", "best_run_axes_thrown", 0)
        _shake_modifier = ini.get_num("game", "shake_modifier", 1)
        _total_runs = ini.get_num("game", "total_runs", 0)
        _fullscreen = ini.get_bool("game", "fullscreen", false)
        _sum_parries = ini.get_num("game", "sum_parries", 0)
        _sum_kills = ini.get_num("game", "sum_kills", 0)
        _sum_props_destroyed = ini.get_num("game", "sum_props_destroyed", 0)
        _sum_npcs_killed = ini.get_num("game", "sum_npcs_killed", 0)
        _sum_axes_thrown = ini.get_num("game", "sum_axes_thrown", 0)
    }

    // Checks if a highscore was achieved and records the run
    check_highscore() { 
        if (score > highscore) {
            _highscore = _score
            _best_run_parries = _total_parries
            _best_run_kills = _total_kills
            _best_run_items = _items.copy()
            _best_run_highest_stage = _total_highest_stage
            _best_run_props_destroyed = _total_props_destroyed
            _best_run_npcs_killed = _total_npcs_killed
            _best_run_axes_thrown = _total_axes_thrown
            return true
        }
        return false
    }

    // Should be called at the end of runs
    save() {
        var ini = INI.open("save.ini")
        ini.set_num("game", "volume", _volume)
        ini.set_bool("game", "crt_effect", _crt_effect)
        ini.set_num("game", "ui_scale", _ui_scale)
        ini.set_string("game", "best_run_items", _best_run_items.save_to_string())
        ini.set_num("game", "highscore", highscore)
        ini.set_num("game", "best_run_parries", best_run_parries)   
        ini.set_num("game", "best_run_kills", best_run_kills) 
        ini.set_num("game", "best_run_highest_stage", best_run_highest_stage) 
        ini.set_num("game", "best_run_props_destroyed", best_run_props_destroyed)   
        ini.set_num("game", "best_run_npcs_killed", best_run_npcs_killed)   
        ini.set_num("game", "best_run_axes_thrown", best_run_axes_thrown)   
        ini.set_num("game", "shake_modifier", _shake_modifier)
        ini.set_bool("game", "fullscreen", _fullscreen)
        ini.set_bool("game", "beaten_game", _beaten_game)
        ini.set_num("game", "total_runs", _total_runs)
        ini.set_num("game", "sum_parries", _sum_parries)
        ini.set_num("game", "sum_kills", _sum_kills)
        ini.set_num("game", "sum_props_destroyed", _sum_props_destroyed)
        ini.set_num("game", "sum_npcs_killed", _sum_npcs_killed)
        ini.set_num("game", "sum_axes_thrown", _sum_axes_thrown)
        ini.flush("save.ini")
    }

    // Called when the game is restarted
    restart() {
        _items.restart()
        _stage = 1
        _score = 0
        _total_parries = 0
        _total_kills = 0
        _total_highest_stage = 0
        _total_props_destroyed = 0
        _total_npcs_killed = 0
        _total_axes_thrown = 0
        _oops_all_wizards = false
    }

    crt_effect { _crt_effect }
    crt_effect=(s) { _crt_effect = s }
    oops_all_wizards { _oops_all_wizards }
    oops_all_wizards=(s) { _oops_all_wizards = s }
    beaten_game { _beaten_game }
    beaten_game=(s) { _beaten_game = s }
    best_run_items { _best_run_items }
    best_run_parries { _best_run_parries }
    best_run_kills { _best_run_kills }
    best_run_highest_stage { _best_run_highest_stage }
    best_run_props_destroyed { _best_run_props_destroyed }
    best_run_npcs_killed { _best_run_npcs_killed }
    best_run_axes_thrown { _best_run_axes_thrown }
    total_parries { _total_parries }
    total_parries=(s) { 
        _total_parries = s 
        _sum_parries = _sum_parries + 1
    }
    total_kills { _total_kills }
    total_kills=(s) { 
        _total_kills = s 
        _sum_kills = _sum_kills + 1
    }
    total_highest_stage { _total_highest_stage }
    total_highest_stage=(s) { _total_highest_stage = s }
    total_props_destroyed { _total_props_destroyed }
    total_props_destroyed=(s) { 
        _total_props_destroyed = s 
        _sum_props_destroyed = _sum_props_destroyed + 1
    }
    total_npcs_killed { _total_npcs_killed }
    total_npcs_killed=(s) { 
        _total_npcs_killed = s 
        _sum_npcs_killed = _sum_npcs_killed + 1
    }
    total_axes_thrown { _total_axes_thrown }
    total_axes_thrown=(s) { 
        _total_axes_thrown = s 
        _sum_axes_thrown = _sum_axes_thrown + 1
    }
    total_runs { _total_runs }
    total_runs=(s) { _total_runs = s }
    highscore=(s) { _highscore = s }
    highscore { _highscore }
    sum_parries { _sum_parries }
    sum_kills { _sum_kills }
    sum_props_destroyed { _sum_props_destroyed }
    sum_npcs_killed { _sum_npcs_killed }
    sum_axes_thrown { _sum_axes_thrown }
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
    stage=(s) { 
        _stage = s 
        if (s > _total_highest_stage) {
            _total_highest_stage = s
        }
    }
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
        Assets.spr_levelnames.scale_x = _ui_scale
        Assets.spr_levelnames.scale_y = _ui_scale
        Assets.spr_levelnameswizards.scale_x = _ui_scale
        Assets.spr_levelnameswizards.scale_y = _ui_scale
    }
}

var Save = SaveImpl.new()
Save.load()