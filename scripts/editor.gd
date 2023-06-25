class_name Editor
extends Control


enum Mode {EDIT, PLACE}

var level: Level

@export var current_block: PackedScene = null:
	set(value):
		current_block = value
		if value != null:
			preview_block = value.instantiate() as IBlock
			preview_block.process_mode = PROCESS_MODE_DISABLED
			preview_block.modulate.a = 0.4
			add_child(preview_block)
		else:
			remove_child(preview_block)
			preview_block = null

@export var mode := Mode.PLACE:
	set = _set_mode

@export var preview_block: IBlock = null

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
		else:
			mode = Mode.PLACE


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var block_pos := level.get_map_position_at_mouse(true)
		block_pos = block_pos + level.tilemap.position
		if preview_block != null:
			preview_block.position = block_pos


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	if mode == Mode.EDIT:
		mode_label.text = "Edit"
		preview_block.hide()
	else:
		Game.currently_opened_gui = null;
		mode_label.text = "Place"
		preview_block.show()
