extends Node2D

@export var room_coords: Vector2i = Vector2i.ZERO

@onready var resource_container = $ResourceContainer
@onready var enemy_container = $EnemyContainer
@onready var spawn_points = $SpawnPoints

func _ready():
	# 1. Get room state from WorldManager
	var state = WorldManager.get_room_state(room_coords)

	# 2. Spawn persistent dropped items
	for item in state.get("dropped_items", []):
		spawn_item(item["id"], item["position"])

	# 3. Spawn resources (if not yet gathered)
	if state.get("resources_spawned", false) == false:
		spawn_resources()
		state["resources_spawned"] = true

	# 4. Spawn enemies (optional)
	if state.get("enemies_cleared", false) == false:
		spawn_enemies()

func spawn_item(item_id: String, position_arg: Vector2):
	var item_scene = preload("res://scenes/ResourceItem.tscn")
	var item = item_scene.instantiate()
	item.item_id = item_id
	item.global_position = position_arg
	resource_container.add_child(item)

func spawn_resources():
	# Example: spawn at a spawn point
	if spawn_points.has_node("ResourceSpawn1"):
		var pos = spawn_points.get_node("ResourceSpawn1").global_position
		spawn_item("wood", pos)

func spawn_enemies():
	# Example stub (replace with real enemy spawner)
	print("Spawning enemies at ", room_coords)
