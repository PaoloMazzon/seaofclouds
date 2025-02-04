import "Constants" for Constants

class FloatingText is Entity {
    construct new() { 
        super()
        _time = Constants.FLOATING_TEXT_DURATION
        _text = ""
        _effect = false
    }

    text=(s) { _text = s }
    text { _text }
    effect { _effect }
    effect=(s) { _effect = s }

    static create_floating_text(level, x, y, text) {
        var t = level.add_entity(FloatingText)
        t.x = x - Assets.fnt_monogram.size(text)[0] / 2
        t.y = y
        t.text = text
    }
    static create_floating_text(level, x, y, text, effect) {
        var t = level.add_entity(FloatingText)
        t.x = x - Assets.fnt_monogram.size(text)[0] / 2
        t.y = y
        t.text = text
        t.effect = effect
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
        if (effect) {
            percent = 0.5
            Renderer.draw_font_ext(Assets.fnt_monogram, "[~2][#000000]" + text, x + 1, y - 16 - (16 * (1 - percent)) + 1)
            Renderer.draw_font_ext(Assets.fnt_monogram, "[~2][*]" + text, x, y - 16 - (16 * (1 - percent)))
        } else {
            Renderer.draw_font(Assets.fnt_monogram, text, x, y - 16 - (16 * (1 - percent)))
        }
        Renderer.colour_mod = [1, 1, 1, 1]
    }
}