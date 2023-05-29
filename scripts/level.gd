class_name Level
extends Node


@onready var camera := $Camera as Camera2D
@onready var edit_ray_cast := $EditRayCast as RayCast2D
@onready var floor_body := $Floor as StaticBody2D
@onready var player := $Player as Player
@onready var tilemap := $TileMap as TileMap

@export var paused := false:
	set = _set_paused
@export var spawn_position: Marker2D
@export var speed := 600
@export var time_scale := 1.0


func _ready() -> void:
	spawn_position = $SpawnPosition as Marker2D
	player.position = spawn_position.position
	Game.level = self
	player.level = self


func _physics_process(_delta: float) -> void:
	floor_body.global_position.x = camera.global_position.x - get_viewport().get_visible_rect().size.x / 2

	if !player.dead:
		tilemap.position.x -= speed * _delta * time_scale

	edit_ray_cast.position = camera.get_global_mouse_position()
	if edit_ray_cast.is_colliding() && paused && Input.is_action_just_pressed("Click"):
		var collider := edit_ray_cast.get_collider()

		if collider is IBlock:
			var block := collider as IBlock
			block.open_edit_gui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		paused = !paused


func _set_paused(value: bool) -> void:
	paused = value
	time_scale = 0.0 if value else 1.0
	if !value:
		Game.currently_opened_gui = null


func reset_to_spawn_position() -> void:
	tilemap.position = Vector2.ZERO
	player.position.y = spawn_position.position.y
