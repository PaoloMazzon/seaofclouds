class SaveImpl {
    construct new() {
        _volume = 1
        _ui_scale = 1
    }

    volume { _volume }
    volume=(s) { _volume = s }
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
    }
}

var Save = SaveImpl.new()