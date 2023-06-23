class_name Editor
extends Control


enum Mode {EDIT, PLACE}

var level: Level

@export var current_block: PackedScene = null
@export var mode := Mode.PLACE

@onready var mode_label := $ModeLabel as RichTextLabel


func _ready() -> void:
	Game.editor = self
	mode_label.text = "Place"


func _process(_delta: float) -> void:
	if Input.is_action_pressed("Click"):
		if current_block != null && mode == Mode.PLACE:
			var block := current_block.instantiate() as IBlock
			level.set_block_at_mouse(block, true)

	if Input.is_action_pressed("Action Click"):
		level.remove_block_at_mouse()

	if Input.is_action_just_pressed("Toggle Editor Mode"):
		if mode == Mode.PLACE:
			mode = Mode.EDIT
			mode_label.text = "Edit"
		else:
			Game.currently_opened_gui = null;
			mode = Mode.PLACE
			mode_label.text = "Place"


func _on_gui_input(event: InputEvent):
	pass
