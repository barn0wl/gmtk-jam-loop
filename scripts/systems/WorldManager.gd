extends Node

var persistent_data := {}  # key = Vector2i (room coords), value = room state
		
func init_room_state_if_needed(coords: Vector2i):
	if not persistent_data.has(coords):
		persistent_data[coords] = {
			"dropped_items": [],
			"enemies_defeated": [],
			"structures_built": {}
	}

func register_dropped_item(coords: Vector2i, item_id: String, position: Vector2):
	init_room_state_if_needed(coords)
	persistent_data[coords]["dropped_items"].append({
		"id": item_id,
		"position": position
	})

func get_room_state(coords: Vector2i) -> Dictionary:
	init_room_state_if_needed(coords)
	return persistent_data[coords]

func remove_dropped_item(coords: Vector2i, item_id: String, position: Vector2):
	if not persistent_data.has(coords):
		return

	var drops = persistent_data[coords]["dropped_items"]
	for i in range(drops.size()):
		var drop = drops[i]
		if drop["id"] == item_id and drop["position"].distance_to(position) < 4.0:
			drops.remove_at(i)
			return
			
	print("Removed dropped item: ", item_id, " from room ", coords)
