extends Node

@onready var footstep = $Footstep
@onready var explosion_mine = $ExplosionMine
@onready var keyboard = $Keyboard
@onready var meteor_impact = $MeteorImpact
@onready var oxygen_warning = $OxygenWarning
@onready var gunshot = $Gunshot

var master_bus
var music_bus
var sfx_bus
var ui_bus

func _ready():
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	ui_bus = AudioServer.get_bus_index("UI")
	
	footstep = $Footstep
	explosion_mine = $ExplosionMine
	keyboard = $Keyboard
	meteor_impact = $MeteorImpact
	oxygen_warning = $OxygenWarning
	gunshot = $Gunshot
	
	
func set_master_volume(value):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))

func set_music_volume(value):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func set_sfx_volume(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func set_ui_volume(value):
	AudioServer.set_bus_volume_db(ui_bus, linear_to_db(value))

func fire_bullet():
	gunshot.play()
	
func explode_mine():
	explosion_mine.play()
	
func meteor_impact_effect():
	meteor_impact.play()
	
func keyboard_effect():
	keyboard.play()

func oxygen_warn():
	oxygen_warning.play()
	
func oxygen_warn_stop():
	oxygen_warning.stop()
	
func footstep_effect():
	footstep.pitch_scale = randf_range(0.8, 1.0)
	footstep.play()
	
