import "Constants" for Constants

class FloatingText is Entity {
    construct new() { 
        super()
        _time = Constants.FLOATING_TEXT_DURATION
        _text = ""
    }

    text=(s) { _text = s }
    text { _text }

    static create_floating_text(level, x, y, text) {
        var t = level.add_entity(FloatingText)
        t.x = x - Assets.fnt_kennypixel.size(text)[0] / 2
        t.y = y
        t.text = text
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        
    }

    update(level) {
        super.update(level)
        if (!level.is_paused) {
            _time = _time - Engine.delta
            if (_time < 0) {
                level.remove_entity(this)
            }
        }
    }

    draw(level) {
        var percent = _time / Constants.FLOATING_TEXT_DURATION
        Renderer.colour_mod = [1, 1, 1, percent]
        Renderer.draw_font(Assets.fnt_kennypixel, text, x, y - 16 - (16 * (1 - percent)))
        Renderer.colour_mod = [1, 1, 1, 1]
    }
}