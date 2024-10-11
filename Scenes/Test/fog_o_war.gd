extends Node2D

const LightTexture = preload("res://Assets/images/Light.png")
const GRID_SIZE = 32

@onready var player: Player = %"Player"
@onready var fog: Sprite2D = $"FoW Sprite"

var d_width = ProjectSettings.get("display/window/size/viewport_width")
var d_height = ProjectSettings.get("display/window/size/viewport_height")

var fogImage = Image.new()
var fogTexture = ImageTexture.new()
var lightImage = LightTexture.get_image()
var light_offset = Vector2(LightTexture.get_width()/2, LightTexture.get_height()/2)

func _ready():
	var fog_image_width = d_width / GRID_SIZE
	var fog_image_height = d_height / GRID_SIZE
	
	fogImage = Image.create_empty(fog_image_width * 10, fog_image_height * 10, false, Image.FORMAT_RGBAH)
	fogImage.fill(Color.BLACK)
	
	lightImage.convert(Image.FORMAT_RGBAH)
	fog.scale *= GRID_SIZE


func update_fog(new_grid_position):
	var light_rect = Rect2(Vector2.ZERO, Vector2(lightImage.get_width(), lightImage.get_height()))
	fogImage.blend_rect(lightImage, light_rect, new_grid_position - light_offset)
	
	update_fog_image_texture()

func update_fog_image_texture():
	fogTexture = ImageTexture.create_from_image(fogImage)
	fog.texture = fogTexture

func _process(event):
	update_fog(to_local(player.position) / GRID_SIZE)
	
