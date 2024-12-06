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
    }

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
    }

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

    // Call to update controls
    update() {

    }

    // Call to draw menu
    draw() {

    }
}