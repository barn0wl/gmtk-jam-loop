extends Node

var persistent_data := {}  # key = Vector2i (room coords), value = room state
		
func init_room_state_if_needed(coords: Vector2i):
	if not persistent_data.has(coords):
		persistent_data[coords] = {}

func get_room_state(coords: Vector2i) -> Dictionary:
	init_room_state_if_needed(coords)
	return persistent_data[coords]
