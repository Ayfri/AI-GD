class_name Level
extends Node

var _mouse_offset := Vector2(-10, 32)
var _old_mouse_position := Vector2.ZERO

@onready var camera := $Camera as Camera2D
@onready var editor_gui := $Editor as Editor
@onready var edit_ray_cast := $EditRayCast as RayCast2D
@onready var floor_body := $Floor as StaticBody2D
@onready var place_ray_cast := $TileMap/PlaceRayCast as RayCast2D
@onready var player := $Player as Player
@onready var tilemap := $TileMap as TileMap

@export var paused := false:
	set = _set_paused

@export_file var save_file_path := "user://save.level"
@export var spawn_position: Marker2D
@export var speed := 600
@export var time_scale := 1.0


func _ready() -> void:
	spawn_position = $SpawnPosition as Marker2D
	Game.level = self
	editor_gui.level = self
	player.level = self
	paused = false
	reset_to_spawn_position()
	load_level()


func _physics_process(_delta: float) -> void:
	floor_body.global_position.x = camera.global_position.x - get_viewport().get_visible_rect().size.x / 2

	if !player.dead:
		tilemap.position.x -= speed * _delta * time_scale

	edit_ray_cast.position = camera.get_global_mouse_position()
	if edit_ray_cast.is_colliding() && paused && Input.is_action_just_pressed("Click"):
		var collider := edit_ray_cast.get_collider()

		if collider is IBlock:
			var block := collider as IBlock
#			block.open_edit_gui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		paused = !paused

	if event.is_action_pressed("Save Level"):
		save()

	if event.is_action_pressed("Load Level"):
		load_level()
		reset_to_spawn_position()

	if event.is_action_pressed("Reset Level"):
		reset_to_spawn_position()


func _mouse_pos_as_map_pos() -> Vector2:
	var mouse_pos := _world_position_to_map_position(camera.get_global_mouse_position())
	_old_mouse_position = mouse_pos
	return mouse_pos


func _set_paused(value: bool) -> void:
	paused = value
	editor_gui.visible = value
	editor_gui.set_process(value)
	time_scale = 0.0 if value else 1.0
	if !value:
		Game.currently_opened_gui = null


func _world_position_to_map_position(world_position: Vector2) -> Vector2:
	return tilemap.to_local(world_position) - _mouse_offset


func disable_tilemap_collisions() -> void:
	tilemap.collision_animatable = false


func enable_tilemap_collisions() -> void:
	tilemap.collision_animatable = true


func get_block_at_mouse() -> IBlock:
	return get_block(_mouse_pos_as_map_pos())


func get_block(position: Vector2) -> IBlock:
	place_ray_cast.target_position = place_ray_cast.position - position - _mouse_offset
	place_ray_cast.position = position + _mouse_offset
	place_ray_cast.force_raycast_update()

	if place_ray_cast.is_colliding():
		var collider := place_ray_cast.get_collider()
		if collider is IBlock:
			var block := collider as IBlock
			return block

	return null


func load_level() -> void:
	if !FileAccess.file_exists(save_file_path):
		print("No save file found")
		return

	tilemap.clear()
	for tile in tilemap.get_children():
		if !tile is IBlock: continue
		tile.queue_free()

	var save_file := FileAccess.open(save_file_path, FileAccess.READ)
	var save_dict := JSON.parse_string(save_file.get_as_text()) as Dictionary
	save_file.close()

	var tiles := save_dict["tiles"] as Array
	for tile in tiles:
		var data := tile as Dictionary
		var scene_path := data["scene_path"] as String
		if !scene_path.contains("/"):
			scene_path = "res://scenes/blocks/" + scene_path

		var tile_scene := ResourceLoader.load(scene_path + ".tscn")
		var tile_instance := tile_scene.instantiate() as IBlock
		tilemap.add_child(tile_instance)
		tile_instance.load(data)

	spawn_position.position = Vector2(
		save_dict["spawn_pos"]["x"] as float,
		save_dict["spawn_pos"]["y"] as float,
	)


func remove_block_at_mouse() -> void:
	remove_block(_mouse_pos_as_map_pos())


func remove_block(position: Vector2) -> void:
	var block := get_block(position)
	if block == null: return
	block.queue_free()


func reset_to_spawn_position() -> void:
	player.sprite.rotation = 0
	player.velocity = Vector2.ZERO
	tilemap.position = Vector2.ZERO
	player.position.y = spawn_position.position.y
	player.position.x = spawn_position.position.x


func save() -> void:
	var tiles: Array[Dictionary] = []
	var tile_scenes := tilemap.get_tree()
	for tile in tile_scenes.get_nodes_in_group("block"):
		if !tile is IBlock: continue
		var block := tile as IBlock
		tiles.append(block.save())

	var save_dict := {
		"tiles": tiles,
		"spawn_pos": {
			"x": spawn_position.position.x,
			"y": spawn_position.position.y,
		},
	}

	var save_file := FileAccess.open(save_file_path, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_dict))
	save_file.close()
	print("Saved level")


func set_block_at_mouse(block_instance: IBlock, snap_to_grid := true) -> void:
	set_block(_mouse_pos_as_map_pos(), block_instance, snap_to_grid)


func set_block(position: Vector2, block_instance: IBlock, snap_to_grid := true) -> void:
	var old_block := get_block(position)
	if old_block != null:
		if old_block.get_class() != block_instance.get_class(): remove_block(position)
		else: return

	if snap_to_grid: position = position.snapped(tilemap.tile_set.tile_size)

	tilemap.add_child(block_instance)
	block_instance.position = position
	block_instance.position += _mouse_offset
