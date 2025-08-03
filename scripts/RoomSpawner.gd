extends Node

@onready var layout_container = $"../LayoutContainer"
@onready var resource_container = $"../ResourceContainer"
@onready var enemy_container = $"../EnemyContainer"
@onready var exit_container = $"../ExitContainer"

@export var room_coords: Vector2i
const EXIT_SCENE = preload("res://scenes/Exit.tscn")
var _already_spawned := false

func spawn_all():
	if _already_spawned:
		print("Skipping spawn: already done")
		return
	_already_spawned = true

	print("Spawning in room:", room_coords)

	spawn_exits()
	spawn_final_exit()
	spawn_key()
	spawn_clock_pickups()
	spawn_energy_orbs()
	spawn_enemies()

# === MARKER LOOKUP ===

func find_markers_in_container(group_name: String) -> Array:
	var markers := []
	for child in layout_container.get_children():
		if child.is_in_group(group_name):
			markers.append(child)
		if child.has_method("get_children"):
			for grandchild in child.get_children():
				if grandchild.is_in_group(group_name):
					markers.append(grandchild)
	return markers

# === INDIVIDUAL SPAWN METHODS ===

func spawn_exits():
	for marker in find_markers_in_container("exit_spawns"):
		var direction = extract_spawn_id(marker.name, "Exit")
		if direction != "":
			var exit = EXIT_SCENE.instantiate()
			exit.direction = direction
			exit.global_position = marker.global_position
			exit_container.call_deferred("add_child", exit)

func spawn_final_exit():
	for marker in find_markers_in_container("final_exit_spawn"):
		var exit_scene = preload("res://scenes/Exit_Final.tscn")
		var exit = exit_scene.instantiate()
		exit.global_position = marker.global_position
		exit_container.call_deferred("add_child", exit)

func spawn_key():
	for marker in find_markers_in_container("key_spawns"):
		var item = preload("res://scenes/ResourceItem.tscn").instantiate()
		item.item_id = "key"
		item.global_position = marker.global_position
		resource_container.call_deferred("add_child", item)

func spawn_clock_pickups():
	var markers = find_markers_in_container("clock_spawns")
	print("Found clock markers:", markers.size())
	for marker in markers:
		var item = preload("res://scenes/ResourceItem.tscn").instantiate()
		item.item_id = "clock"
		item.global_position = marker.global_position
		resource_container.call_deferred("add_child", item)

func spawn_energy_orbs():
	for marker in find_markers_in_container("energy_spawns"):
		var item = preload("res://scenes/ResourceItem.tscn").instantiate()
		item.item_id = "energy_orb"
		item.global_position = marker.global_position
		resource_container.call_deferred("add_child", item)

func spawn_enemies():
	for marker in find_markers_in_container("enemy_spawns"):
		var enemy_type = extract_spawn_id(marker.name, "EnemySpawn")
		if enemy_type != "":
			var path = "res://scenes/Enemy/%s.tscn" % enemy_type.capitalize()
			var scene = load(path)
			if scene:
				var enemy = scene.instantiate()
				enemy.global_position = marker.global_position
				enemy_container.call_deferred("add_child", enemy)

# === HELPER ===

func extract_spawn_id(marker_name: String, prefix: String) -> String:
	var pattern = "^%s_([^_]+)" % prefix
	var regex = RegEx.new()
	if regex.compile(pattern) == OK:
		var match = regex.search(marker_name)
		if match:
			return match.get_string(1)
	return ""
