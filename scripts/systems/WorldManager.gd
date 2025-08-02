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
	var uid = generate_item_uid(item_id, position)
	persistent_data[coords]["dropped_items"].append({
		"id": item_id,
		"position": position,
		"uid": uid
	})

func get_room_state(coords: Vector2i) -> Dictionary:
	init_room_state_if_needed(coords)
	return persistent_data[coords]

func remove_dropped_item(coords: Vector2i, uid: String):
	if not persistent_data.has(coords):
		print("No data for room:", coords)
		return

	var drops = persistent_data[coords]["dropped_items"]
	print("Trying to remove UID: ", uid)
	for i in range(drops.size()):
		var drop = drops[i]
		print("Checking drop:", drop)
		if drop.has("uid") and drop["uid"] == uid:
			drops.remove_at(i)
			print("Removed dropped item (uid): ", uid, " from room ", coords)
			return

	print("Failed to remove drop. UID not found.")

func generate_item_uid(item_id: String, position: Vector2) -> String:
	return item_id + "_" + str(position.round())
