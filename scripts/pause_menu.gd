class_name PauseMenu
extends Control


var level: Level

@onready var play_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/PlayButton as Button
@onready var restart_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/RestartButton as Button

signal resume_game
signal restart_game


func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Pause Menu"):
		resume_game.emit()


func _on_play_button_pressed() -> void:
	resume_game.emit()


func _on_restart_button_pressed() -> void:
	restart_game.emit()
