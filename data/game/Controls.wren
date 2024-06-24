class ControlsImpl {
    construct new() {}

    movement_x { Keyboard.keys_as_axis(Keyboard.KEY_LEFT, Keyboard.KEY_RIGHT) }
    movement_y { Keyboard.keys_as_axis(Keyboard.KEY_UP, Keyboard.KEY_DOWN) }
    skill_check { Keyboard.key_pressed(Keyboard.KEY_SPACE) }
    attack { Keyboard.key_pressed(Keyboard.KEY_Z) }
    parry { Keyboard.key(Keyboard.KEY_X) }
    restart { Keyboard.key_pressed(Keyboard.KEY_R) }
}

var Controls = ControlsImpl.new()