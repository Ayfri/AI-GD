class_name IBlock
extends StaticBody2D


const BLOCK_GUI_SCENE := preload("res://scenes/block_gui.tscn")

@onready var collision_shape := $HitBox as CollisionPolygon2D
@onready var sprite := $Sprite as Sprite2D

@export var kills_player := false
@export var level: Level = null
@export var texture: Texture2D:
	get:
		return sprite.texture
	set(value):
		texture = value
		sprite.set_texture(value)


func _ready() -> void:
	level = Game.level


func load(data: Dictionary) -> void:
	kills_player = data.get("kills_player", false)
	position = Vector2(data["pos"]["x"], data["pos"]["y"])
	rotation = data.get("rot", 0)

	var atlas := AtlasTexture.new()
	atlas.atlas = Game.BLOCKS_ATLAS_PATH.duplicate()
	atlas.region = Rect2(
		data["texture_rect"]["x"],
		data["texture_rect"]["y"],
		data["texture_rect"].get("width", 64),
		data["texture_rect"].get("height", 64),
	)
	texture = atlas


func save() -> Dictionary:
	var sprite_atlas := sprite.texture as AtlasTexture
	var texture_rect := sprite_atlas.region
	var texture_rect_dict := {
		"x": texture_rect.position.x,
		"y": texture_rect.position.y,
	}

	if texture_rect.size.x != 64:
		texture_rect_dict["width"] = texture_rect.size.x
	if texture_rect.size.y != 64:
		texture_rect_dict["height"] = texture_rect.size.y

	var file_path := get_scene_file_path()
	# gives only the file name if the scene is in the scenes/blocks folder
	# also removes the .tscn extension
	file_path = file_path.replace(".tscn", "")
	if file_path.begins_with("res://scenes/blocks/"):
		file_path = file_path.replace("res://scenes/blocks/", "")

	var dict := {
		"pos": {
			"x": position.x,
			"y": position.y,
		},
		"scene_path": file_path,
		"texture_rect": texture_rect_dict,
	}

	if kills_player:
		dict["kills_player"] = true

	if rotation != 0:
		dict["rot"] = rotation

	return dict


func open_edit_gui() -> void:
	var edit_gui := Game.open_gui(BLOCK_GUI_SCENE, global_position)
	print("edit_gui: ", edit_gui)
	print("edit_gui2: ", edit_gui as BlockGui)
	var edit_gui2 := edit_gui as BlockGui
	edit_gui2.block = self
