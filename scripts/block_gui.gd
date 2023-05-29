class_name BlockGui
extends Control


@onready var rotation_slider := %RotationSlider as HSlider

@export var block: IBlock
@export var hold_step_size := 45


func _on_rotation_slider_value_changed(value: float) -> void:
	if block == null: return

	if Input.is_action_pressed("Hold Editor"):
		rotation_slider.step = hold_step_size
	else:
		rotation_slider.step = 1

	block.rotation_degrees = value
