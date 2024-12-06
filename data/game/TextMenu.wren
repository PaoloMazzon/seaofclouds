// A small wrapper for readability of a menu option
class MenuOption {
    static TYPE_SLIDER { 0 } // Value is 0-1
    static TYPE_RADIO { 1 } // Value is true/false
    static TYPE_NONE { 2 } // No value is passed to the fiber upon execution

    construct new(new_name, new_fiber, new_type, default_value) {
        _name = new_name
        _fiber = new_fiber
        _type = new_type
        _value = default_value
    }

    construct new(new_name, new_fiber, new_type) {
        _name = new_name
        _fiber = new_fiber
        _type = new_type
        _value = 0
    }

    // Call this if the user clicks the menu option
    update() {
        if (type == MenuOption.TYPE_NONE) {
            fiber.call()
        } else if (type == MenuOption.TYPE_RADIO) {
            _value = !_value
            fiber.call(value)
        }
    }

    // Call this if the user moves the cursor left, will not impact the wrong type
    update_value_left() {
        if (type == MenuOption.TYPE_SLIDER) {
            _value = _value - 0.05
            if (_value < 0) {
                _value = 1
            }
        }
    }

    // Call this if the user moves the cursor left, will not impact the wrong type
    update_value_right() {
        if (type == MenuOption.TYPE_SLIDER) {
            _value = _value + 0.05
            if (_value > 1) {
                _value = 0
            }
        }
    }

    name { _name }
    fiber { _fiber }
    value { _value }
    type { _type }
}

// A series of options
class SubMenu {
    construct new() {
        _options = [] // list of MenuOption
        _surface = null
    }
    surface=(s) { _surface = s }
    surface { _surface }

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
    construct new() { 
        _menus = {"top": SubMenu.new()}
        _cursor = 0
        _menu = "top"
        _global_x = 0
        _global_y = 0
        _font = Assets.fnt_kingdom
        _x_offset = 0 // menu option moves by this much horizontally each option
        _y_offset = 0 // menu option moves this much vertically + font height each option
    }

    global_x { _global_x }
    global_x=(s) { _global_x = s }
    global_y { _global_y }
    global_y=(s) { _global_y = s }
    font { _font }
    font=(s) { 
        _font = s
    }
    x_offset { _x_offset }
    x_offset=(s) { _x_offset = s }
    y_offset { _y_offset }
    y_offset=(s) { _y_offset = s }

    // Adds a menu and returns it
    add_menu(name) {
        var m = SubMenu.new()
        _menus["name"] = m
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
            var x = 0
            var y = 0
            var height = _font.size("|")[1]

            for (option in _menus[_menu]) {
                x = x + x_offset
                y = y + y_offset + height
            }

            // Create surface of necessary dimensions
            menu.surface = Surface.new(x, y)

            // Draw to the surface
            Renderer.target = menu.surface
            Renderer.clear_blank()
            x = 0
            y = 0

            for (option in _menus[_menu]) {
                Renderer.draw_font(font, option.name, x, y)
                x = x + x_offset
                y = y + y_offset + height
            }
            Renderer.target = Renderer.RENDER_TARGET_DEFAULT
        }
    }

    // Call to update controls
    update() {
        
    }

    // Call to draw menu
    draw() {
        // Text is stored on the surface and sliders/radio boxes/the cursor is drawn dynamically
        var x = _global_x
        var y = _global_y
        var height = _font.size("|")[1]

        for (option in _menus[_menu]) {
            Renderer.draw_font(font, option.name, x, y)
            x = x + x_offset
            y = y + y_offset + height
            // TODO: Sliders and radio boxes
        }
    }
}