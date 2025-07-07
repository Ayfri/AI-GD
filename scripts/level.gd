class_name Level
extends Node


const MOUSE_OFFSET := Vector2(0, 32)
const PAUSE_MENU_SCENE := preload("res://scenes/pause_menu.tscn")

@onready var camera := $Camera as Camera2D
@onready var editor_gui := $Editor as Editor
@onready var edit_ray_cast := $EditRayCast as RayCast2D
@onready var floor_body := $Floor as StaticBody2D
@onready var game_hud := $GameHUD as GameHUD
@onready var place_ray_cast := $TileMap/PlaceRayCast as RayCast2D
@onready var player := $Player as Player
@onready var tilemap := $TileMap as TileMap

@export var editor_active := false:
	set = _set_editor_active
@export var paused := false:
	set = _set_paused

var pause_menu: PauseMenu = null
var ui_consuming_input := false
var initial_spawn_position: Vector2
var initial_tilemap_position: Vector2
var initial_camera_position: Vector2

@export_file var save_file_path := "user://save.level"
@export var spawn_position: Marker2D
@export var speed := 600
@export var time_scale := 1.0


func _ready() -> void:
	spawn_position = $SpawnPosition as Marker2D
	initial_spawn_position = spawn_position.position
	initial_tilemap_position = tilemap.position
	initial_camera_position = camera.position
	Game.level = self
	editor_gui.level = self
	game_hud.level = self
	player.level = self
	paused = false
	reset_to_spawn_position()
	load_level()
	# Corriger l'état initial de l'éditeur
	editor_active = editor_active


func _physics_process(_delta: float) -> void:
	floor_body.global_position.x = camera.global_position.x

	if !player.dead and !paused:
		tilemap.position.x -= speed * _delta * time_scale

	edit_ray_cast.position = get_mouse_position()
	place_ray_cast.position = get_map_position_at_mouse()
	if edit_ray_cast.is_colliding() && editor_active && Input.is_action_just_pressed("Click"):
		var collider := edit_ray_cast.get_collider()

		if collider is IBlock && editor_gui.mode == Editor.Mode.EDIT:
			var block := collider as IBlock
			block.open_edit_gui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Pause Menu"):
		toggle_pause_menu()

	if event.is_action_pressed("Toggle Editor"):
		# Ne pas pouvoir activer l'éditeur si le menu pause est ouvert
		if pause_menu == null:
			editor_active = !editor_active

	if event.is_action_pressed("Save Level"):
		save()

	if event.is_action_pressed("Load Level"):
		load_level()
		reset_to_spawn_position()

	if event.is_action_pressed("Reset Level"):
		reset_to_spawn_position()


func _set_editor_active(value: bool) -> void:
	editor_active = value
	editor_gui.visible = value
	editor_gui.set_process(value)
	game_hud.visible = !value
	if value:
		# Fermer le menu pause si l'éditeur est activé
		if pause_menu != null:
			_hide_pause_menu()
		paused = true
		time_scale = 0.0
	else:
		if pause_menu == null:
			paused = false
			time_scale = 1.0
		Game.currently_opened_gui = null


func _set_paused(value: bool) -> void:
	paused = value
	if !editor_active:
		time_scale = 0.0 if value else 1.0


func toggle_pause_menu() -> void:
	if pause_menu == null:
		_show_pause_menu()
	else:
		_hide_pause_menu()


func _show_pause_menu() -> void:
	pause_menu = PAUSE_MENU_SCENE.instantiate() as PauseMenu
	pause_menu.level = self
	pause_menu.resume_game.connect(_hide_pause_menu)
	pause_menu.restart_game.connect(_restart_game)
	pause_menu.save_level.connect(_on_save_level)
	pause_menu.load_level.connect(_on_load_level)
	add_child(pause_menu)
	paused = true


func _hide_pause_menu() -> void:
	if pause_menu != null:
		pause_menu.queue_free()
		pause_menu = null
		if !editor_active:
			paused = false


func _restart_game() -> void:
	_hide_pause_menu()
	# Recharger complètement la scène
	get_tree().reload_current_scene()


func _on_save_level() -> void:
	save()


func _on_load_level() -> void:
	load_level()
	reset_to_spawn_position()


func disable_tilemap_collisions() -> void:
	tilemap.collision_animatable = false


func enable_tilemap_collisions() -> void:
	tilemap.collision_animatable = true


func get_block_at_mouse() -> IBlock:
	return get_block(get_map_position_at_mouse())


func get_map_position_at_mouse(snap_to_grid := false) -> Vector2:
	return world_position_to_map_position(get_mouse_position(), snap_to_grid)


func get_mouse_position() -> Vector2:
	return editor_gui.get_local_mouse_position()


func get_block(position: Vector2) -> IBlock:
	place_ray_cast.target_position = place_ray_cast.position - position
	place_ray_cast.position = position
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
	remove_block(get_map_position_at_mouse())


func remove_block(position: Vector2) -> void:
	var block := get_block(position)
	if block == null: return
	block.queue_free()


func reset_to_spawn_position() -> void:
	player.sprite.rotation = 0
	player.velocity = Vector2.ZERO
	tilemap.position = initial_tilemap_position
	player.position.y = spawn_position.position.y
	player.position.x = spawn_position.position.x
	player.dead = false
	player.sprite.show()
	enable_tilemap_collisions()


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
	set_block(get_map_position_at_mouse(snap_to_grid), block_instance)


func set_block(position: Vector2, block_instance: IBlock) -> void:
	var old_block := get_block(position)
	if old_block != null:
		if old_block.get_class() != block_instance.get_class(): remove_block(position)
		else: return

	tilemap.add_child(block_instance)
	block_instance.position = position


func world_position_to_map_position(world_position: Vector2, snap_to_grid := false) -> Vector2:
	var position := world_position - tilemap.position
	if snap_to_grid:
		var tile_size := Vector2(tilemap.tile_set.tile_size)
		var half_tile := tile_size / 2
		return (position / tile_size).floor() * tile_size + half_tile
	else:
		return position


func is_click_on_ui() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()

	# Vérifier si la souris est sur le bouton de pause
	if game_hud.visible:
		var pause_button = game_hud.pause_button
		var button_rect = Rect2(pause_button.global_position, pause_button.size)
		if button_rect.has_point(mouse_pos):
			return true

	# Vérifier si un menu est ouvert
	return pause_menu != null or editor_active
