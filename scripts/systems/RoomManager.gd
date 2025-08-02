extends Node2D

const ROOM_SCENE = preload("res://scenes/Room.tscn")
const ROOM_SIZE = Vector2i(320, 180)  # adjust to your tilemap dimensions

var active_rooms: Dictionary = {}  # key: Vector2i, value: Room instance
var current_room_coords: Vector2i = Vector2i.ZERO

func load_room(coords: Vector2i):
	if active_rooms.has(coords):
		return

	var room = ROOM_SCENE.instantiate()
	room.room_coords = coords
	add_child(room)
	room.position = coords * ROOM_SIZE
	active_rooms[coords] = room

	WorldManager.init_room_state_if_needed(coords)

func unload_room(coords: Vector2i):
	if active_rooms.has(coords):
		active_rooms[coords].queue_free()
		active_rooms.erase(coords)

func move_to_room(direction: Vector2i):
	var new_coords = current_room_coords + direction
	unload_room(current_room_coords)
	load_room(new_coords)
	current_room_coords = new_coords

	# Move player to new room origin
	var player = get_node("/root/Main/Player")
	player.global_position = new_coords * ROOM_SIZE + Vector2(32, 32)  # e.g., spawn offset
