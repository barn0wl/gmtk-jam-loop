extends Area2D

@export var item_id: String = "clock"

var _picked_up := false  # Prevent multiple triggers

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	update_sprite_icon()

func update_sprite_icon():
	var item_data = ItemDatabase.get_item(item_id)
	if item_data.has("icon"):
		$Sprite2D.texture = item_data["icon"]
	else:
		push_warning("No icon found for item: " + item_id)

func _on_body_entered(body: Node) -> void:
	print("COLLISION -", item_id)
	if _picked_up: return  # 🧯 Prevent multiple collisions
	if not body.is_in_group("player"): return

	_picked_up = true  # Lock trigger
	
	match item_id:
		"clock":
			TimeManager.reduce_time(-10.0)
		"energy_orb":
			if body.has_method("recharge_energy"):
				body.recharge_energy(1)
		"key":
			GameManager.collect_key()

	queue_free()
