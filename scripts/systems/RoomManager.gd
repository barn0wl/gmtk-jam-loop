extends Node2D

const ROOM_SCENE = preload("res://scenes/Room.tscn")
const ROOM_PADDING := Vector2(16, 16)
@export var room_size := Vector2(320, 180)
@export var max_rooms := 10

var active_rooms := {}               # key: Vector2i, value: Room instance
var room_graph := {}                # key: Vector2i, value: {connected: [...], has_key: false, ...}
var current_room_coords := Vector2i.ZERO

var special_rooms := {
	"start": Vector2i.ZERO,
	"key": Vector2i.ZERO,
	"exit": Vector2i.ZERO
}

func _ready():
	randomize()  # Ensure all randf/randi calls are properly randomized
	generate_new_level()

func generate_new_level():
	clear_rooms()
	room_graph = RoomGraphGenerator.new().generate_graph(Vector2i.ZERO, max_rooms)
	special_rooms = choose_special_rooms(room_graph)

	instantiate_rooms()
	call_deferred("build_all_rooms")  # <- DEFER this

	# Also defer moving the player to avoid race conditions
	call_deferred("move_player_to_room", special_rooms.start)

func clear_rooms():
	for room in active_rooms.values():
		room.queue_free()
	active_rooms.clear()

# === Room Setup ===

func instantiate_rooms():
	for coords in room_graph.keys():
		var room_instance = ROOM_SCENE.instantiate()
		var room: Room = room_instance as Room
		
		if not room:
			push_error("Failed to cast room to Room class!")
			continue
			
		room.room_coords = coords

		room.is_key_room = coords == special_rooms.key
		room.is_final_exit_room = coords == special_rooms.exit
		room.is_start_room = coords == special_rooms.start

		print("ROOM INSTANCE:", room)
		print("HAS PROPERTY:", room.has_method("build_room"), " | ", "connected_neighbors" in room)
		assert(room is Room, "Room isn't the expected class!")
		room.connected_neighbors.assign(room_graph[coords]["connected"])
		
		var world_pos := Vector2(coords) * (room_size + ROOM_PADDING)
		room.position = world_pos

		add_child(room)
		active_rooms[coords] = room

func build_all_rooms():
	for room in active_rooms.values():
		room.build_room()

# === Player & Camera ===

func move_player_to_room(coords: Vector2i):
	var player := get_player()
	if not player: return

	var center := get_room_center(coords)
	player.global_position = center
	move_camera_to(center)

	current_room_coords = coords

func get_room_center(coords: Vector2i) -> Vector2:
	var base := Vector2(coords) * (room_size + ROOM_PADDING)
	return base + room_size / 2

func move_camera_to(coords: Vector2):
	var camera := get_camera()
	if camera:
		camera.global_position = coords

# === Access Helpers ===

func get_player() -> Node:
	return get_tree().current_scene.get_node_or_null("World/Player")

func get_camera() -> Camera2D:
	return get_tree().current_scene.get_node_or_null("RoomManager/GameCamera")

# === Special Room Assignment ===

func choose_special_rooms(graph: Dictionary) -> Dictionary:
	var coords := graph.keys()
	if coords.is_empty():
		push_error("Room graph is empty!")
		return {"start": Vector2i.ZERO, "key": Vector2i.ZERO, "exit": Vector2i.ZERO}

	var start = coords.pick_random()

	# Try to pick key room at a reasonable distance
	var far_candidates = coords.filter(func(c): return c != start and c.distance_to(start) > 2)
	var key = far_candidates.pick_random() if not far_candidates.is_empty() else coords.filter(func(c): return c != start).pick_random()

	# Try to pick exit room different from key and start
	var exit_candidates = coords.filter(func(c): return c != start and c != key and c.distance_to(start) > 2)
	var exit = exit_candidates.pick_random() if not exit_candidates.is_empty() else coords.filter(func(c): return c != start and c != key).pick_random()

	# Fallback to any random node if needed
	if key == null: key = coords.pick_random()
	if exit == null: exit = coords.pick_random()

	return {
		"start": start,
		"key": key,
		"exit": exit
	}

func move_to_room(direction: String):
	var current = current_room_coords
	var candidate = get_neighbor_in_direction(current, direction)

	if candidate != null and room_graph.has(candidate):
		move_player_to_room(candidate)
	else:
		print("No room in direction:", direction)

func get_neighbor_in_direction(coords: Vector2i, direction: String):
	var offset: Vector2i
	match direction:
		"up":
			offset = Vector2i(0, -1)
		"down":
			offset = Vector2i(0, 1)
		"left":
			offset = Vector2i(-1, 0)
		"right":
			offset = Vector2i(1, 0)
		_:
			offset = Vector2i.ZERO

	var neighbor = coords + offset
	var connected = room_graph[coords].get("connected", [])

	if neighbor in connected:
		return neighbor
	else:
		return null
