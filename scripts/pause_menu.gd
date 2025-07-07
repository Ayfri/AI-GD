class_name PauseMenu
extends Control


var level: Level

@onready var play_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/PlayButton as Button
@onready var save_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/SaveButton as Button
@onready var load_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/LoadButton as Button
@onready var save_date_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/SaveDateLabel as Label
@onready var restart_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/RestartButton as Button

var check_timer: Timer

signal resume_game
signal restart_game
signal save_level
signal load_level


func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)

	# Créer un timer pour vérifier l'état toutes les secondes
	check_timer = Timer.new()
	check_timer.wait_time = 1.0
	check_timer.timeout.connect(_update_load_button_state)
	check_timer.autostart = true
	add_child(check_timer)

	_update_load_button_state()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Pause Menu"):
		resume_game.emit()


func _on_play_button_pressed() -> void:
	resume_game.emit()


func _on_save_button_pressed() -> void:
	save_level.emit()
	# Attendre un petit moment puis actualiser pour s'assurer que la sauvegarde est terminée
	await get_tree().process_frame
	_update_load_button_state()


func _on_load_button_pressed() -> void:
	load_level.emit()


func _on_restart_button_pressed() -> void:
	restart_game.emit()


func _update_load_button_state() -> void:
	var save_file_path := "user://save.level"
	var has_save_file := FileAccess.file_exists(save_file_path)

	# Griser le bouton si pas de sauvegarde
	load_button.disabled = !has_save_file
	if !has_save_file:
		load_button.modulate = Color(0.5, 0.5, 0.5, 1.0)
		save_date_label.text = "Aucune sauvegarde disponible"
	else:
		load_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
		_update_save_date_label(save_file_path)


func _update_save_date_label(file_path: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		save_date_label.text = ""
		return

	var file_time := FileAccess.get_modified_time(file_path)
	file.close()

	var datetime := Time.get_datetime_dict_from_unix_time(file_time)
	var date_string := "%02d/%02d/%04d - %02d:%02d" % [
		datetime.day, datetime.month, datetime.year,
		datetime.hour, datetime.minute
	]
	save_date_label.text = "Dernière sauvegarde : " + date_string


func _exit_tree() -> void:
	if check_timer:
		check_timer.queue_free()
