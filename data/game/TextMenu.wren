import "Controls" for Controls
import "Save" for Save

// A small wrapper for readability of a menu option
class MenuOption {
    static TYPE_SLIDER { 0 } // Value is 0-1
    static TYPE_RADIO { 1 } // Value is true/false
    static TYPE_NONE { 2 } // No value is passed to the fiber upon execution

    construct new(new_name, new_fn, new_type, default_value) {
        _name = new_name
        _fn = new_fn
        _type = new_type
        _value = default_value
        _hidden = false
    }

    construct new(new_name, new_fn, new_type) {
        _name = new_name
        _fn = new_fn
        _type = new_type
        _value = 0
        _hidden = false
    }

    construct new_hidden(new_name, new_fn, new_type, default_value) {
        _name = new_name
        _fn = new_fn
        _type = new_type
        _value = default_value
        _hidden = true
    }

    construct new_hidden(new_name, new_fn, new_type) {
        _name = new_name
        _fn = new_fn
        _type = new_type
        _value = 0
        _hidden = true
    }

    // Call this if the user clicks the menu option
    update() {
        if (type == MenuOption.TYPE_RADIO) {
            _value = !_value
            fn.call(value)
        } else if (type == MenuOption.TYPE_RADIO || type == MenuOption.TYPE_SLIDER) {
            fn.call(value)
        } else {
            fn.call()
        }
    }

    // Call this if the user moves the cursor left, will not impact the wrong type - returns true if it did something
    update_value_left() {
        if (type == MenuOption.TYPE_SLIDER) {
            if (_value <= 0.01) {
                _value = 1
            } else {
                _value = _value - 0.05
            }
            return true
        }
        return false
    }

    // Call this if the user moves the cursor left, will not impact the wrong type - returns true if it did something
    update_value_right() {
        if (type == MenuOption.TYPE_SLIDER) {
            if (_value >= 1) {
                _value = 0
            } else {
                _value = _value + 0.05
            }
            return true
        }
        return false
    }

    name { _name }
    fn { _fn }
    value { _value }
    type { _type }
    hidden { _hidden }
}

// A series of options
class SubMenu {
    construct new() {
        _options = [] // list of MenuOption
        _surface = null
        _x_offset = 0
        _y_offset = 0
    }
    surface=(s) { _surface = s }
    surface { _surface }
    x_offset { _x_offset }
    x_offset=(s) { _x_offset = s }
    y_offset { _y_offset }
    y_offset=(s) { _y_offset = s }

    // Adds an option to this sub menu
    add_option(option) {
        _options.add(option)
    }

    // Indexing into the inner list
    count { _options.count }
    [index] {
        return _options[index]
    }

    // Support for for-loops
    iterate(iter) {
        if (iter == null) {
            return 0
        } else if (iter == _options.count - 1) {
            return false
        } else {
            return iter + 1
        }
    }

    iteratorValue(iter) {
        return _options[iter]
    }
}

// A text-based menu, not meant to be derived
class TextMenu {
    static ALIGN_LEFT { 0 }
    static ALIGN_TOP { 0 }
    static ALIGN_RIGHT { 1 }
    static ALIGN_BOTTOM { 1 }
    static ALIGN_CENTER { 2 }

    construct new() { 
        _menus = {"top": SubMenu.new()}
        _cursor = 0
        _menu = "top"
        _font = Assets.fnt_menufont
        _x_offset = 0 // menu option moves by this much horizontally each option
        _y_offset = 0 // menu option moves this much vertically + font height each option
        _align_x = TextMenu.ALIGN_LEFT
        _align_y = TextMenu.ALIGN_LEFT

        // Cursor position
        _cursor_x = -1
        _cursor_y = -1
    }

    move_cursor_to(x, y, ui_scale) {
        // To account for the cursor jumping into position at startup
        if (_cursor_x == -1 || _cursor_y == -1) {
            _cursor_x = x
            _cursor_y = y
        } else {
            _cursor_x = _cursor_x + ((x - _cursor_x) * 12 * Engine.delta) + ((5 * Engine.time).sin * ui_scale * 0.5) - (ui_scale * 0.5)
            _cursor_y = _cursor_y + ((y - _cursor_y) * 12 * Engine.delta)
        }
    }

    // Getters and setters
    align_x { _align_x }
    align_x=(s) { _align_x = s }
    align_y { _align_y }
    align_y=(s) { _align_y = s }
    font { _font }
    font=(s) { _font = s }
    x_offset { _x_offset }
    x_offset=(s) { _x_offset = s }
    y_offset { _y_offset }
    y_offset=(s) { _y_offset = s }
    current_menu { _menus[_menu] }
    current_width { current_menu.surface.width }
    current_height { current_menu.surface.height }

    // Adds a menu and returns it
    add_menu(name) {
        var m = SubMenu.new()
        _menus[name] = m
        return m
    }

    add_option(menu, option) {
        _menus[menu].add_option()
    }

    [menu] {
        return _menus[menu]
    }

    set_menu(menu) {
        if (_menus.containsKey(menu)) {
            _menu = menu
            _cursor = 0
        }
    }

    set_cursor(index) {
        if (index == -1) {
            index = _menus[_menu].count - 1
        }
        _cursor = index
    }

    top_menu { _menus["top"] } // top-level menu called "top"

    // Stores surfaces for each menu
    finalize() {
        for (key in _menus.keys) {
            // Find necessary width/height
            var menu = _menus[key]
            var height = _font.size("aydbzQq0912p|")[1]
            var x = 0
            var max_x = 0
            var y = 0

            for (option in menu) {
                var size = _font.size(option.name)
                if (x + size[0] > max_x) {
                    max_x = x + size[0]
                }
                x = x + x_offset
                y = y + y_offset + height
            }

            // Create surface of necessary dimensions
            menu.surface = Surface.new(max_x + 2, y + 2)

            // Draw to the surface
            Renderer.target = menu.surface
            Renderer.clear_blank()
            x = 0
            y = 0

            for (option in menu) {
                if (!option.hidden) {
                    Renderer.colour_mod = [0, 0, 0, 0.7]
                    Renderer.draw_font(font, option.name, x + 1, y + 1)
                    Renderer.colour_mod = [1, 1, 1, 1]
                    Renderer.draw_font(font, option.name, x, y)
                }
                x = x + x_offset
                y = y + y_offset + height
            }
            Renderer.target = Renderer.RENDER_TARGET_DEFAULT
        }
    }

    // Call to update controls
    update() {
        if (Controls.menu_up) {
            if (_cursor == 0) {
                _cursor = current_menu.count - 1
            } else {
                _cursor = _cursor - 1
            }
            Audio.play(Assets.aud_menucursor, false, Save.volume, Save.volume)
        }
        if (Controls.menu_down) {
            if (_cursor == current_menu.count - 1) {
                _cursor = 0
            } else {
                _cursor = _cursor + 1
            }
            Audio.play(Assets.aud_menucursor, false, Save.volume, Save.volume)
        }

        if (Controls.menu_left) {
            if (current_menu[_cursor].update_value_left()) {
                current_menu[_cursor].update()
                Audio.play(Assets.aud_menucursor, false, Save.volume, Save.volume)
            }
        }
        if (Controls.menu_right) {
            if (current_menu[_cursor].update_value_right()) {
                current_menu[_cursor].update()
                Audio.play(Assets.aud_menucursor, false, Save.volume, Save.volume)
            }
        }
        if (Controls.menu_confirm) {
            current_menu[_cursor].update()
            Audio.play(Assets.aud_menuselect, false, Save.volume, Save.volume)
        }
    }

    // Call to draw menu
    draw(global_x, global_y, ui_scale) {
        // Handle alignment
        global_x = global_x + (current_menu.x_offset * ui_scale)
        global_y = global_y + (current_menu.y_offset * ui_scale)
        var draw_x = global_x
        var draw_y = global_y
        if (align_x == TextMenu.ALIGN_RIGHT) {
            draw_x = draw_x - (current_menu.surface.width * ui_scale)
        } else if (align_x == TextMenu.ALIGN_CENTER) {
            draw_x = draw_x - ((current_menu.surface.width * ui_scale) / 2)
        }
        if (align_y == TextMenu.ALIGN_RIGHT) {
            draw_y = draw_y - (current_menu.surface.height * ui_scale)
        } else if (align_y == TextMenu.ALIGN_CENTER) {
            draw_y = draw_y - ((current_menu.surface.height * ui_scale) / 2)
        }

        // Text is stored on the surface and sliders/radio boxes/the cursor is drawn dynamically
        Renderer.draw_texture(current_menu.surface, draw_x, draw_y, ui_scale, ui_scale, 0, 0, 0)
        
        // Cursor
        var height = _font.size("|")[1] + y_offset
        move_cursor_to(draw_x - (10 * ui_scale) + (x_offset * _cursor * ui_scale), draw_y + ((height - y_offset) * 0.5 * ui_scale) + (height * _cursor * ui_scale), ui_scale)
        var w = Assets.tex_menucursor.width * ui_scale * 0.5
        var h = Assets.tex_menucursor.height * ui_scale * 0.5
        if (!(current_menu.count == 1 && current_menu[0].hidden)) {
            Renderer.draw_texture(Assets.tex_menucursor, _cursor_x - w, _cursor_y - h, ui_scale, ui_scale, 0, 0, 0)
        }

        var x = draw_x
        var y = draw_y
        for (option in _menus[_menu]) {
            // Where to position elements
            var size = _font.size(option.name)
            var pos_x = x + (size[0] * ui_scale) + ui_scale
            var pos_y = y + ((size[1] * ui_scale) / 2) + ui_scale // this is centered

            // Draw slider
            if (option.type == MenuOption.TYPE_SLIDER) {
                var final_y = pos_y - (Assets.tex_menubar.height * ui_scale * 0.5)
                Renderer.draw_texture(Assets.tex_menubar, pos_x, final_y, ui_scale, ui_scale, 0, 0, 0)
                Renderer.colour_mod = "#a6b6cc"
                var unnormalized = option.value * 69
                Renderer.draw_rectangle(pos_x + (ui_scale * 2), final_y + (ui_scale * 2), ui_scale * unnormalized, 9 * ui_scale, 0, 0, 0)
                Renderer.colour_mod = [1, 1, 1, 1]
            }

            // Draw radio box
            if (option.type == MenuOption.TYPE_RADIO) {
                var final_y = pos_y - (Assets.tex_menuradiobox.height * ui_scale * 0.5)
                var tex = Assets.tex_menuradiobox
                if (option.value) {
                    tex = Assets.tex_menuradioboxchecked
                }
                Renderer.draw_texture(tex, pos_x, final_y, ui_scale, ui_scale, 0, 0, 0)
            }

            // Update position
            x = x + (x_offset * ui_scale)
            y = y + (height * ui_scale)
        }
    }
}