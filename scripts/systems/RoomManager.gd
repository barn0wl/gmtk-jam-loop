extends Node2D

const EXIT_BUFFER = 32
const ROOM_SCENE = preload("res://scenes/Room.tscn")
const GRID_RADIUS = 1

const ROOM_PRESET_MAP = {
	Vector2i(0, 0): "res://scenes/room_presets/Preset_01.tscn",
	Vector2i(0, 1): "res://scenes/room_presets/Preset_01.tscn",
	Vector2i(1, 0): "res://scenes/room_presets/Preset_01.tscn",
}

const DEFAULT_PRESET_PATH = "res://scenes/room_presets/Preset_01.tscn"

var ROOM_PADDING: Vector2 = Vector2(16, 16)
@export var room_size: Vector2 = Vector2(320, 180)

var active_rooms: Dictionary = {}
var current_room_coords: Vector2i = Vector2i.ZERO

func _ready():
	generate_initial_grid()
	call_deferred("build_all_rooms")
	move_player_to_room(Vector2i.ZERO)

func generate_initial_grid():
	for x in range(-GRID_RADIUS, GRID_RADIUS + 1):
		for y in range(-GRID_RADIUS, GRID_RADIUS + 1):
			var coords = Vector2i(x, y)
			load_room(coords)

func build_all_rooms():
	for coords in active_rooms.keys():
		active_rooms[coords].build_room()

func load_room(coords: Vector2i):
	if active_rooms.has(coords):
		return

	var room = ROOM_SCENE.instantiate()
	room.room_coords = coords
	room.room_preset_path = ROOM_PRESET_MAP.get(coords, DEFAULT_PRESET_PATH)

	add_child(room)
	room.position = Vector2(coords) * (room_size + ROOM_PADDING)
	active_rooms[coords] = room

	WorldManager.init_room_state_if_needed(coords)

func unload_room(coords: Vector2i):
	if active_rooms.has(coords):
		active_rooms[coords].queue_free()
		active_rooms.erase(coords)

func get_player() -> Node:
	return get_tree().current_scene.get_node_or_null("World/Player")

func get_camera() -> Camera2D:
	return get_tree().current_scene.get_node_or_null("RoomManager/GameCamera")

func move_player_to_room(coords: Vector2i):
	var player = get_player()
	if player:
		var offset = room_size / 2
		var base_pos = Vector2(coords) * (room_size + ROOM_PADDING)
		var target_pos = base_pos + offset
		player.global_position = target_pos

	move_camera_to_room_center(coords)
	current_room_coords = coords

func move_to_room(direction: String):
	var offset: Vector2i
	match direction:
		"up": offset = Vector2i(0, -1)
		"down": offset = Vector2i(0, 1)
		"left": offset = Vector2i(-1, 0)
		"right": offset = Vector2i(1, 0)
		_: offset = Vector2i.ZERO

	var new_coords = current_room_coords + offset

	unload_room(current_room_coords)
	load_room(new_coords)
	call_deferred("build_all_rooms")  # Optionally re-init if rooms are loaded dynamically

	move_player_into_room(direction, new_coords)
	current_room_coords = new_coords

func move_player_into_room(from_direction: String, target_coords: Vector2i):
	print("🔁 Moving player into room:", target_coords, "from:", from_direction)

	var player = get_player()
	var offset: Vector2

	match from_direction:
		"up": offset = Vector2(room_size.x / 2, room_size.y - EXIT_BUFFER)
		"down": offset = Vector2(room_size.x / 2, EXIT_BUFFER)
		"left": offset = Vector2(room_size.x - EXIT_BUFFER, room_size.y / 2)
		"right": offset = Vector2(EXIT_BUFFER, room_size.y / 2)
		_: offset = room_size / 2

	var base_pos = Vector2(target_coords) * (room_size + ROOM_PADDING)
	var target_pos = base_pos + offset

	if player:
		player.global_position = target_pos

	move_camera_to_room_center(target_coords)

func move_camera_to_room_center(coords: Vector2i):
	var camera = get_camera()
	if camera:
		var base_pos = Vector2(coords) * (room_size + ROOM_PADDING)
		var center_pos = base_pos + (room_size / 2)

		camera.global_position = center_pos
		print("📷 Moved camera to:", center_pos)
