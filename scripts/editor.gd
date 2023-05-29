class_name Editor
extends Control


var level: Level

@export var current_block: PackedScene = null


func _ready() -> void:
	Game.editor = self


func _process(_delta: float) -> void:
	if Input.is_action_pressed("Click"):
		if current_block != null:
			var block := current_block.instantiate() as IBlock
			level.set_block_at_mouse(block, true)

	if Input.is_action_pressed("Action Click"):
		level.remove_block_at_mouse()


func _on_gui_input(event: InputEvent):
	pass
