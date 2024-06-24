class ControlsImpl {
    construct new() {}

    movement_x { 
        var k = Keyboard.keys_as_axis(Keyboard.KEY_LEFT, Keyboard.KEY_RIGHT) 
        var l = Gamepad.button(0, Gamepad.BUTTON_DPAD_LEFT)
        var r = Gamepad.button(0, Gamepad.BUTTON_DPAD_RIGHT)
        var g = (l ? -1 : 0) + (r ? 1 : 0)
        var s = Gamepad.left_stick_x(0)
        return (k == 0 ? (g == 0 ? s : g) : k)
    }
    movement_y { 
        var k = Keyboard.keys_as_axis(Keyboard.KEY_UP, Keyboard.KEY_DOWN) 
        var l = Gamepad.button(0, Gamepad.BUTTON_DPAD_UP)
        var r = Gamepad.button(0, Gamepad.BUTTON_DPAD_DOWN)
        var g = (l ? -1 : 0) + (r ? 1 : 0)
        var s = Gamepad.left_stick_y(0)
        return (k == 0 ? (g == 0 ? s : g) : k)
    }
    skill_check { Keyboard.key_pressed(Keyboard.KEY_SPACE) || Gamepad.button_pressed(0, Gamepad.BUTTON_A) }
    attack { Keyboard.key_pressed(Keyboard.KEY_Z) || Gamepad.button_pressed(0, Gamepad.BUTTON_X) }
    parry { Keyboard.key(Keyboard.KEY_X) || Gamepad.button(0, Gamepad.BUTTON_B) }
    restart { Keyboard.key_pressed(Keyboard.KEY_R) || Gamepad.button_pressed(0, Gamepad.BUTTON_BACK) }
    on_gamepad { Gamepad.is_connected(0) }
}

var Controls = ControlsImpl.new()