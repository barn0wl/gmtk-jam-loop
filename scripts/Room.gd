extends Node2D

@export var room_coords: Vector2i = Vector2i.ZERO
@export var room_preset_path: String = ""

@onready var layout_container = $LayoutContainer

func build_room():
	load_preset_layout(room_preset_path)
	await get_tree().process_frame
	_init_spawner_after_layout()
	_update_debug_label()

func load_preset_layout(path: String) -> void:
	var preset = load(path)
	if preset:
		var instance = preset.instantiate()
		layout_container.add_child(instance)
	else:
		push_error("Failed to load preset: " + path)

func _init_spawner_after_layout():
	var spawner = $RoomSpawner
	spawner.room_coords = room_coords
	spawner.spawn_all()

func _update_debug_label():
	var label = get_node_or_null("DebugLabel")
	if label and label is Label:
		label.text = "Room: " + str(room_coords)
