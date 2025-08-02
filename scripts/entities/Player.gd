extends CharacterBody2D

@export var move_speed: float = 150.0
@export var max_health: int = 100
var health: int = max_health

var inventory := []  # simple inventory array (e.g., item IDs or references)
var equipped_item: Dictionary = {}  # Currently equipped item data (id, amount, data)

# Movement input
func _physics_process(_delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * move_speed
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	print("Player took ", amount, " damage. HP: ", health)
	if health <= 0:
		die()

func die():
	print("Player died.")
	GameManager.game_over()

# Utility
func is_alive() -> bool:
	return health > 0

func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	
func add_to_inventory(item_id: String, amount: int) -> void:
	if not ItemDatabase.item_exists(item_id):
		print("Invalid item: ", item_id)
		return
		
	var item_data = ItemDatabase.get_item(item_id)
	
	if item_data.get("stackable", true):
		# try stacking (simple logic for now)
		inventory.append({"id": item_id, "amount": amount})
	else:
		for i in amount:
			inventory.append({"id": item_id, "amount": 1})

func equip_item(item_id: String) -> void:
	for entry in inventory:
		if entry["id"] == item_id:
			var item_data = ItemDatabase.get_item(item_id)
			if item_data.get("equippable", false):
				equipped_item = {
					"id": item_id,
					"amount": entry["amount"],
					"data": item_data
				}
				print("Equipped: ", item_id)
				return
			else:
				print(item_id, " is not equippable.")
				return
	print("Item not found in inventory: ", item_id)
	
func use_weapon(item: Dictionary) -> void:
	print("Attacking with ", item["id"])
	# TODO: trigger hitbox, animation, etc.

func use_tool(item: Dictionary) -> void:
	if item["id"] == "torch":
		print("Torch active!")
		# TODO: toggle a Light2D child node on/off, spawn light source, etc.

func use_consumable(item: Dictionary) -> void:
	# Sample effect: healing
	if item["data"].has("heal_amount"):
		heal(item["data"]["heal_amount"])
		print("Used ", item["id"], " to heal.")
		# remove 1 from inventory
		
func use_equipped_item() -> void:
	if equipped_item.is_empty():
		print("No item equipped.")
		return

	var item_type = equipped_item["data"].get("type", "")

	match item_type:
		"weapon":
			use_weapon(equipped_item)
		"tool":
			use_tool(equipped_item)
		"consumable":
			use_consumable(equipped_item)
		_:
			print("Cannot use item of type: ", item_type)
			
func drop_item(item_id: String):
	var item_scene = preload("res://scenes/ResourceItem.tscn")
	var drop = item_scene.instantiate()
	drop.item_id = item_id
	drop.register_in_world = true
	drop.global_position = global_position + Vector2(16, 0)

	var room = get_tree().current_scene.get_node("World")
	room.add_child(drop)
