extends Node


const BLOCKS_ATLAS_PATH := preload("res://assets/sprites/atlas.png")

@export var currently_opened_gui: Control = null:
	set(value):
		if currently_opened_gui != null:
			currently_opened_gui.queue_free()
		currently_opened_gui = value
@export var level: Level = null


func open_gui(gui: PackedScene, pos: Vector2i) -> Control:
	var gui_node := gui.instantiate() as Control
	gui_node.global_position = pos
	level.add_child(gui_node)
	currently_opened_gui = gui_node
	return gui_node
