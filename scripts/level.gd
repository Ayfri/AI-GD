class_name Level
extends Node


@onready var camera := $Camera as Camera2D
@onready var floor_body := $Floor as StaticBody2D
@onready var player := $Player as Player
@onready var tilemap := $TileMap as TileMap

@export var spawn_position: Marker2D
@export var speed := 600


func _ready() -> void:
	spawn_position = $SpawnPosition as Marker2D
	player.position = spawn_position.position
	Game.level = self
	player.level = self


func _physics_process(_delta: float) -> void:
	floor_body.global_position.x = camera.global_position.x - get_viewport().get_visible_rect().size.x / 2

	if !player.dead:
		tilemap.position.x -= speed * _delta


func reset_to_spawn_position() -> void:
	tilemap.position = Vector2.ZERO
	player.position.y = spawn_position.position.y
