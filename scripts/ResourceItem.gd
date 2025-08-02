extends Area2D

@export var item_id: String = "wood"
@export var quantity: int = 1

signal picked_up(item_id: String, quantity: int)

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	update_sprite_icon()

func update_sprite_icon():
	var item_data = ItemDatabase.get_item(item_id)
	if item_data.has("icon"):
		var sprite = $Sprite2D
		sprite.texture = item_data["icon"]
	else:
		push_warning("No icon found for item: " + item_id)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("add_to_inventory"):
			body.add_to_inventory(item_id, quantity)
		emit_signal("picked_up", item_id, quantity)

		# Notify WorldManager
		remove_from_world_manager()

		queue_free()

func remove_from_world_manager():
	# Try to access parent room
	var room = get_parent()
	while room and not room.has_variable("room_coords"):
		room = room.get_parent()

	if room and room.has_variable("room_coords"):
		var coords = room.room_coords
		WorldManager.remove_dropped_item(coords, item_id, global_position)
	else:
		push_warning("ResourceItem could not find its room_coords")
