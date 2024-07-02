import "StartCutscene" for StartCutscene
import "Save" for Save

Save.load()

var renderer_config = {
	"window_title": "Game",
	"window_width": 1600,
	"window_height": 900,
	"fullscreen": Save.fullscreen,
	"msaa": Renderer.MSAA_32X,
	"screen_mode": Renderer.SCREEN_MODE_TRIPLE_BUFFER,
	"filter_type": Renderer.FILTER_TYPE_NEAREST
}

System.print(Engine.info)
Engine.fps_limit = 144
Engine.delta_max = 1/30

var minimum_load_time = 0
var window_icon = "icon.png"
var start_level = StartCutscene.new()