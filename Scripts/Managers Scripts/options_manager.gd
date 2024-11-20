extends Node


const options_path = "user://options.data"

var DEFAULT_OPTIONS = {
	"window_width": 1280,
	"window_height": 720,
	"full_screen" : false,
	"ui_volume" : 1.0,
	"master_volume": 1.0,
	"music_volume" : 1.0,
	"sfx_volume": 1
}


var window_size_list = [
	{"width": 1024, "height": 768},
	{"width": 1280, "height": 720},
	{"width": 1366, "height": 768},
	{"width": 1600, "height": 900},
	{"width": 1920, "height": 1080},
]

func read_options():
	var options = {}
	var file = FileAccess.open(options_path, FileAccess.READ)
	
	if file:
		options = file.get_var()
		file.close()
	else:
		write_options(DEFAULT_OPTIONS)
		return DEFAULT_OPTIONS
	
	return options
	

func write_options(options):
	var file = FileAccess.open(options_path, FileAccess.WRITE)
	file.store_var(options)
	file.close()


func set_window_mode():
	var window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	var options = read_options()
	if options.has("full_screen"):
		window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if options.full_screen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(window_mode)
	write_options(options)

func resize_window():
	var options = read_options()
	if not options.has("full_screen") or not options.full_screen:
		var window_size = Vector2i(options.window_width, options.window_height)
		var screen_size = DisplayServer.screen_get_size()
		get_window().size = window_size
		DisplayServer.window_set_position(Vector2i((screen_size.x - window_size.x) / 2, (screen_size.y - window_size.y) / 2))
