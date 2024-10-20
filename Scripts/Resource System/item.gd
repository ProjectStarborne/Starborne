class_name Item extends Resource

# If you need to create a new item, just go into res://data/items and create a new resource under this class.
@export var name : String
@export var scene : PackedScene
@export var icon : Texture
@export var price : int
@export var weight : int
@export var description : String
@export var stackable : bool
@export var quantity : int
