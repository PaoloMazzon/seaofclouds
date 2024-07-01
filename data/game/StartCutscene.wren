import "Menu" for Menu
import "Controls" for Controls
import "CameraManager" for CameraManager
import "Save" for Save

class AnimationTween {
    construct new(start_x, start_y, final_x, final_y, scale_start, scale_end, start_time, end_time, fade_in, fade_out, tex) {
        _start_x = start_x
        _start_y = start_y
        _scale_start = scale_start
        _scale_end = scale_end
        _final_x = final_x
        _final_y = final_y
        _start_time = start_time
        _end_time = end_time
        _fade_in = fade_in
        _fade_out = fade_out
        _texture = tex
    }

    draw(time) {
        if (time < _start_time || time > _end_time) {
            return
        }
        var relative_time = time - _start_time
        var percent = relative_time / (_end_time - _start_time)
        var alpha = 1
        if (_fade_in != 0 && relative_time < _fade_in) {
            alpha = relative_time / _fade_in
        } else if (_fade_out != 0 && relative_time > (_end_time - _start_time) - _fade_out) {
            alpha = 1 - ((relative_time - (_end_time - _start_time - _fade_out)) / _fade_out)
        }
        Renderer.colour_mod = [1, 1, 1, alpha]

        // Its a fade in/out
        if (_texture == null) {
            Renderer.draw_rectangle(0, 0, Renderer.window_width, Renderer.window_height, 0, 0, 0)
        } else {
            // Moving texture
            var scale = Math.lerp(percent, _scale_start, _scale_end)
            var x = Math.lerp(percent, _start_x, _final_x) - (_texture.width * scale * 0.5)
            var y = Math.lerp(percent, _start_y, _final_y) - (_texture.height * scale * 0.5)
            Renderer.draw_texture(_texture, x, y, scale, scale, 0, 0, 0)
        }

        Renderer.colour_mod = [1, 1, 1, 1]
    }
}

class StartCutscene is Level {
    construct new() {}

    create() {
        CameraManager.setup()
        _time = 0
        _animation_time = 25
        _ui_camera = CameraManager.menu_camera
        _draw_surf = Surface.new(300, 200)
        Audio.play(Assets.aud_teleportmusic, false, Save.volume, Save.volume)

        _tweens = []

        // First part
        _tweens.add(AnimationTween.new(
            150,
            120,
            150,
            100,
            1,
            1,
            0,
            8,
            1,
            1,
            Assets.tex_animationslide1
        ))
        _tweens.add(AnimationTween.new(
            46,
            174,
            64,
            121,
            2,
            3,
            0,
            8,
            1,
            1,
            Assets.tex_blacksmith
        ))

        // Slide 2
        _tweens.add(AnimationTween.new(
            150,
            100,
            150,
            100,
            0.8,
            1,
            8,
            16,
            1,
            1,
            Assets.tex_animationslide2
        ))
        _tweens.add(AnimationTween.new(
            150,
            40,
            150,
            40,
            1,
            1,
            8,
            16,
            1,
            1,
            Assets.tex_animationslide2text
        ))
        _tweens.add(AnimationTween.new(
            15,
            150,
            87,
            123,
            2,
            3,
            8,
            16,
            1,
            1,
            Assets.tex_blacksmithback
        ))

        // 3rd frame
        _tweens.add(AnimationTween.new(
            150,
            100,
            150,
            100,
            1,
            4,
            16,
            20,
            1,
            1,
            Assets.tex_garth
        ))
        _tweens.add(AnimationTween.new(
            150,
            90,
            150,
            100,
            1,
            1,
            16,
            20,
            1.5,
            1.5,
            Assets.tex_suitedup
        ))

        // 4th frame
        _tweens.add(AnimationTween.new(
            150,
            110,
            150,
            100,
            1,
            1,
            20,
            25,
            0.5,
            1.5,
            Assets.tex_background
        ))
        _tweens.add(AnimationTween.new(
            150,
            -50,
            150,
            100,
            1,
            1,
            20,
            22,
            0.5,
            0,
            Assets.tex_titlecard
        ))
        _tweens.add(AnimationTween.new(
            150,
            100,
            150,
            100,
            1,
            1,
            22,
            25,
            0,
            1.5,
            Assets.tex_titlecard
        ))
        /*
            _tweens.add(AnimationTween.new(
                start_x,
                start_y,
                final_x,
                final_y,
                scale_start,
                scale_end,
                start_time,
                end_time,
                fade_in,
                fade_out,
                tex
            ))
        */
    }

    pre_frame() {
        _ui_camera.x = 0
        _ui_camera.y = 0
        _ui_camera.width = Renderer.window_width
        _ui_camera.height = Renderer.window_height
        _ui_camera.w_on_screen = Renderer.window_width
        _ui_camera.h_on_screen = Renderer.window_height
        _ui_camera.update()
    }

    update() {
        _time = _time + Engine.delta
        if (_time >= _animation_time || Controls.confirm) {
            Engine.switch_level(Menu.new())
        }

        // Draw animation to texture
        Renderer.target = _draw_surf
        Renderer.colour_mod = [0, 0, 0, 1]
        Renderer.clear()
        Renderer.colour_mod = [1, 1, 1, 1]
        for (tween in _tweens) {
            tween.draw(_time)
        }
        Renderer.target = Renderer.RENDER_TARGET_DEFAULT

        // Draw animation to screen
        var scale = Renderer.window_height / 200
        Renderer.draw_texture(
            _draw_surf,
            (Renderer.window_width / 2) - (150 * scale),
            0,
            scale,
            scale,
            0, 
            0, 
            0
        )
    }

    destroy() {
        Audio.stop_all()
        _draw_surf.free()
    }
}