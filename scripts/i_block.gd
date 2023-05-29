class_name IBlock
extends StaticBody2D


const BLOCK_GUI_SCENE := preload("res://scenes/block_gui.tscn")

@onready var collision_shape := $HitBox as CollisionPolygon2D
@onready var sprite := $Sprite as Sprite2D

@export var kills_player := false
@export var level: Level = null
@export var texture: Texture2D:
	get:
		return sprite.texture
	set(value):
		texture = value
		sprite.set_texture(value)


func _ready() -> void:
	level = Game.level


func open_edit_gui() -> void:
	var edit_gui := Game.open_gui(BLOCK_GUI_SCENE, global_position) as BlockGui
	edit_gui.block = self
