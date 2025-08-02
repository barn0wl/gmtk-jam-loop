extends Area2D

@export var item_id: String = "wood"
@export var quantity: int = 1
@export var register_in_world: bool = false  # only true for dropped items

var uid: String
var room_coords: Vector2i

signal picked_up(item_id: String, quantity: int)

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	update_sprite_icon()

	if register_in_world:
		register_self_to_world()

func update_sprite_icon():
	var item_data = ItemDatabase.get_item(item_id)
	if item_data.has("icon"):
		$Sprite2D.texture = item_data["icon"]
	else:
		push_warning("No icon found for item: " + item_id)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("add_to_inventory"):
			body.add_to_inventory(item_id, quantity)
		emit_signal("picked_up", item_id, quantity)

		remove_from_world_manager()
		queue_free()

func remove_from_world_manager():
	WorldManager.remove_dropped_item(room_coords, uid)

func register_self_to_world():
	WorldManager.register_dropped_item(room_coords, item_id, global_position)
	print("ResourceItem registered in room ", room_coords)
	
