extends Node2D

@export var room_coords: Vector2i = Vector2i.ZERO
@export var room_preset_path: String = "" # e.g. "res://scenes/room_presets/forest_A.tscn"

@onready var layout_container = $LayoutContainer
@onready var resource_container = $ResourceContainer
@onready var enemy_container = $EnemyContainer
@onready var exit_container = $ExitContainer

const EXIT_SCENE = preload("res://scenes/Exit.tscn") # Adjust path as needed

func _ready():
	# DEBUG
	var label = Label.new()
	label.text = "Room " + str(room_coords)
	label.position = Vector2(16, 16)
	add_child(label)

	# Load preset layout
	if room_preset_path != "":
		load_preset_layout(room_preset_path)

	spawn_exits_from_markers()

	# Load world state
	var state = WorldManager.get_room_state(room_coords)

	# Dropped items
	for item in state.get("dropped_items", []):
		spawn_resource(item["id"], item["position"])

	# Resources
	if state.get("resources_spawned", false) == false:
		spawn_resources_from_markers()
		state["resources_spawned"] = true

	# Enemies
	if state.get("enemies_cleared", false) == false:
		spawn_enemies_from_markers()

func load_preset_layout(path: String) -> void:
	var preset = load(path)
	if preset:
		var instance = preset.instantiate()
		layout_container.add_child(instance)
	else:
		push_error("Failed to load preset: " + path)

func spawn_resource(item_id: String, position_arg: Vector2):
	var item_scene = preload("res://scenes/ResourceItem.tscn")
	var item = item_scene.instantiate()
	item.item_id = item_id
	item.global_position = position_arg
	item.room_coords = room_coords  # important
	item.uid = WorldManager.generate_item_uid(item_id, position_arg)
	item.register_in_world = true
	resource_container.call_deferred("add_child", item)

func spawn_enemy(enemy_scene: PackedScene, position_arg: Vector2):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = position_arg
	enemy_container.add_child(enemy)

func spawn_resources_from_markers():
	for marker in layout_container.get_tree().get_nodes_in_group("resource_spawns"):
		var item_id = extract_spawn_id(marker.name, "ResourceSpawn")
		if item_id != "":
			spawn_resource(item_id, marker.global_position)

func spawn_enemies_from_markers():
	for marker in layout_container.get_tree().get_nodes_in_group("enemy_spawns"):
		var enemy_type = extract_spawn_id(marker.name, "EnemySpawn")
		if enemy_type != "":
			var scene_path = "res://scenes/Enemy/%s.tscn" % enemy_type.capitalize()
			var enemy_scene = load(scene_path)
			if enemy_scene:
				spawn_enemy(enemy_scene, marker.global_position)
			else:
				print("Enemy scene not found: ", scene_path)

func spawn_exits_from_markers():
	for marker in layout_container.get_tree().get_nodes_in_group("exit_spawns"):
		var direction = extract_spawn_id(marker.name, "Exit")
		if direction != "":
			var exit = EXIT_SCENE.instantiate()
			exit.direction = direction
			exit.global_position = marker.global_position
			exit_container.call_deferred("add_child", exit)

func extract_spawn_id(marker_name: String, prefix: String) -> String:
	# Match the pattern like "EnemySpawn_slime", "EnemySpawn_slime_1", etc.
	var pattern = "^%s_([^_]+)" % prefix
	var regex = RegEx.new()
	var result = regex.compile(pattern)
	if result == OK:
		var match = regex.search(marker_name)
		if match:
			return match.get_string(1)
	return ""
