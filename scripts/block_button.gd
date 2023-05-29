@tool
class_name BlockButton
extends Control


var selected := false:
	set(value):
		if value == selected: return
		selected = value
		modulate = Color(0.8, 1, 0.8) if value else Color(1, 1, 1)

@onready var texture_rect := $PanelContainer/TextureRect as TextureRect

@export var block_scene: PackedScene = null:
	set(value):
		if value == block_scene: return
		block_scene = value
		update_configuration_warnings()
@export var region_rect := Rect2(0, 0, 1, 1):
	set(value):
		if value == region_rect: return
		region_rect = value
		_update_texture(value)
		update_configuration_warnings()


func _ready():
	_update_texture(region_rect)


func _process(_delta: float) -> void:
	if Game.editor == null: return
	selected = Game.editor.current_block == block_scene


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if texture_rect.texture == null:
		warnings.append("Texture is not set")

	if block_scene == null:
		warnings.append("Block scene is not set")

	if region_rect.size.x == 0 || region_rect.size.y == 0:
		warnings.append("Region is not set")

	return warnings


func _update_texture(rect: Rect2) -> void:
	if texture_rect == null: return

	var atlas_texture := AtlasTexture.new()
	var atlas_region := rect
	atlas_region.size = atlas_region.size * 64
	atlas_region.position = atlas_region.position * 64

	var current_atlas := texture_rect.texture as AtlasTexture
	atlas_texture.atlas = current_atlas.atlas
	atlas_texture.region = atlas_region

	texture_rect.texture = atlas_texture


func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Click"):
		Game.editor.current_block = block_scene
