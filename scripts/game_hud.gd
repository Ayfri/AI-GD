class_name GameHUD
extends Control


var level: Level

@onready var pause_button := $PauseContainer/PauseButton as Button
@onready var pause_container := $PauseContainer as Control


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	pause_container.gui_input.connect(_on_pause_container_gui_input)
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_pause_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()


func _on_pause_button_pressed() -> void:
	if level != null:
		level.toggle_pause_menu()
