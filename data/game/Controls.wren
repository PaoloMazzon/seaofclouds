class ControlsImpl {
    construct new() {
        _prev_x_axis = 0
        _prev_y_axis = 0
        _x_axis = 0
        _y_axis = 0
    }

    update_menu() {
        _prev_x_axis = _x_axis
        _prev_y_axis = _y_axis
        _x_axis = (Gamepad.left_stick_x(0).abs > 0.3) ? Gamepad.left_stick_x(0).sign : 0
        _y_axis = (Gamepad.left_stick_y(0).abs > 0.3) ? Gamepad.left_stick_y(0).sign : 0
    }

    movement_x { 
        var k = Keyboard.keys_as_axis(Keyboard.KEY_LEFT, Keyboard.KEY_RIGHT) 
        var l = Gamepad.button(0, Gamepad.BUTTON_DPAD_LEFT)
        var r = Gamepad.button(0, Gamepad.BUTTON_DPAD_RIGHT)
        var g = (l ? -1 : 0) + (r ? 1 : 0)
        var s = (Gamepad.left_stick_x(0).abs > 0.3) ? Gamepad.left_stick_x(0).sign : 0
        return (k == 0 ? (g == 0 ? s : g) : k)
    }
    movement_y { 
        var k = Keyboard.keys_as_axis(Keyboard.KEY_UP, Keyboard.KEY_DOWN) 
        var l = Gamepad.button(0, Gamepad.BUTTON_DPAD_UP)
        var r = Gamepad.button(0, Gamepad.BUTTON_DPAD_DOWN)
        var g = (l ? -1 : 0) + (r ? 1 : 0)
        var s = (Gamepad.left_stick_y(0).abs > 0.3) ? Gamepad.left_stick_y(0).sign : 0
        return (k == 0 ? (g == 0 ? s : g) : k)
    }
    skill_check { Keyboard.key_pressed(Keyboard.KEY_SPACE) || Gamepad.button_pressed(0, Gamepad.BUTTON_A) }
    confirm { Keyboard.key_pressed(Keyboard.KEY_SPACE) || Gamepad.button_pressed(0, Gamepad.BUTTON_A) }
    attack { Keyboard.key_pressed(Keyboard.KEY_Z) || Gamepad.button_pressed(0, Gamepad.BUTTON_X) }
    throw_axe { Keyboard.key_pressed(Keyboard.KEY_C) || Gamepad.button_pressed(0, Gamepad.BUTTON_Y) }
    parry { Keyboard.key(Keyboard.KEY_X) || Gamepad.button(0, Gamepad.BUTTON_B) }
    restart { Keyboard.key_pressed(Keyboard.KEY_R) || Gamepad.button_pressed(0, Gamepad.BUTTON_BACK) }
    menu_up { Keyboard.key_pressed(Keyboard.KEY_UP) || Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_UP) || (_y_axis == -1 && _prev_y_axis != -1) }
    menu_down { Keyboard.key_pressed(Keyboard.KEY_DOWN) || Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_DOWN) || (_y_axis == 1 && _prev_y_axis != 1) }
    menu_left { Keyboard.key_pressed(Keyboard.KEY_LEFT) || Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_LEFT) }
    menu_right { Keyboard.key_pressed(Keyboard.KEY_RIGHT) || Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_RIGHT) }
    menu_confirm { Keyboard.key_pressed(Keyboard.KEY_RETURN) || Keyboard.key_pressed(Keyboard.KEY_SPACE) || Gamepad.button_pressed(0, Gamepad.BUTTON_A) }
    pause { Keyboard.key_pressed(Keyboard.KEY_ESCAPE) || Gamepad.button_pressed(0, Gamepad.BUTTON_START) }
    on_gamepad { Gamepad.is_connected(0) }
}

var Controls = ControlsImpl.new()