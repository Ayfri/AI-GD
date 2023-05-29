class_name IBlock
extends StaticBody2D


@onready var collision_shape := $HitBox as CollisionPolygon2D
@onready var sprite := $Sprite as Sprite2D

@export var kills_player := false
@export var texture: Texture2D:
	get:
		return sprite.texture
	set(value):
		texture = value
		sprite.set_texture(value)
