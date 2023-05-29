class_name Player
extends CharacterBody2D


var dead := false
var level: Level

@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var sprite := $Sprite as Sprite2D

@export var death_timeout := 0.75
@export var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
@export var jump_force := 1220
@export var rotation_speed := 7


func _physics_process(delta: float) -> void:
	if level.paused: return

	velocity.y += gravity * delta
	move_and_slide()

	for idx in range(get_slide_collision_count()):
		var collision_body := get_slide_collision(idx)
		var collider := collision_body.get_collider()

		if collider is IBlock:
			var block := collider as IBlock
			if block.kills_player:
				die()

			if absi(block.global_position.y - position.y) < 8:
				die()

	if is_on_floor():
		snap_rotation_to_floor()
		if Input.is_action_pressed("jump"):
			jump()
	else:
		rotate_sprite(delta)


func die() -> void:
	if dead: return
	dead = true
	print("Player died")
	sprite.hide()
	animation_player.stop()
	await get_tree().create_timer(death_timeout).timeout
	respawn()


func jump() -> void:
	velocity.y = -jump_force
	animation_player.stop()
	animation_player.play("jump")


func respawn() -> void:
	dead = false
	velocity = Vector2.ZERO
	sprite.rotation_degrees = 0
	sprite.show()
	level.reset_to_spawn_position()


func rotate_sprite(delta: float) -> void:
	sprite.rotate(delta * rotation_speed)


# Snaps rotation to any 90 degree angles based on the floor angle
# For example, if the floor angle is 45 degrees, the sprite will rotate to 45 or 135 or 225 or 315 degrees
func snap_rotation_to_floor() -> void:
	var current_angle := sprite.rotation_degrees
	var floor_angle := get_floor_angle()
	var angle_difference := roundi(current_angle - floor_angle + 180) % 360 - 180
	var snapped_angle: float

	# Calculate the nearest multiple of 90 degrees
	var nearest_multiple_of_90 := roundi(angle_difference / 90.0) * 90.0

	# Set the sprite's rotation to the snapped angle
	snapped_angle = floor_angle + nearest_multiple_of_90
	sprite.rotation_degrees = snapped_angle
