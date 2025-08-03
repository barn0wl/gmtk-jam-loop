extends Node2D

class_name Room

@export var room_coords: Vector2i = Vector2i.ZERO
@export var connected_neighbors: Array[Vector2i] = []
@export var is_start_room: bool = false
@export var is_key_room: bool = false
@export var is_final_exit_room: bool = false

@export var room_size: Vector2 = Vector2(320, 180)

@onready var layout_container = $LayoutContainer
@onready var resource_container = $ResourceContainer
@onready var enemy_container = $EnemyContainer
@onready var exit_container = $ExitContainer
@onready var debug_label = $DebugLabel
@onready var wall_container = $WallContainer

const EXIT_SCENE = preload("res://scenes/Exit.tscn")
const FINAL_EXIT_SCENE = preload("res://scenes/Exit_Final.tscn")
const KEY_SCENE = preload("res://scenes/ResourceItem.tscn")
const CLOCK_SCENE = preload("res://scenes/ResourceItem.tscn")
const ENERGY_SCENE = preload("res://scenes/ResourceItem.tscn")
const ENEMY_SCENE = preload("res://scenes/Enemy.tscn")
const WALL_SCENE = preload("res://scenes/Wall.tscn")

var spawned := false
var occupied_positions := {}

func _ready():
	print("ExitContainer exists:", $ExitContainer != null)
	build_room()

func build_room():
	if spawned:
		return
	spawned = true

	spawn_exits()
	spawn_key()
	spawn_final_exit()
	spawn_clocks()
	spawn_energy_orbs()
	spawn_enemies()
	spawn_walls()
	update_debug_label()

func spawn_exits():
	for neighbor in connected_neighbors:
		var dir = get_direction_to(neighbor)
		if dir != "":
			var exit = EXIT_SCENE.instantiate()
			exit.direction = dir
			exit.global_position = get_exit_position(dir)
			exit_container.add_child(exit)

func spawn_key():
	if not is_key_room:
		return
	var key = KEY_SCENE.instantiate()
	key.item_id = "key"
	key.global_position = get_random_spawn_point()
	resource_container.add_child(key)

func spawn_final_exit():
	if not is_final_exit_room:
		return
	var final = FINAL_EXIT_SCENE.instantiate()
	final.global_position = get_random_spawn_point()
	exit_container.add_child(final)

func spawn_clocks():
	var count = randi() % 3  # 0, 1, 2
	for i in count:
		var clock = CLOCK_SCENE.instantiate()
		clock.item_id = "clock"
		clock.global_position = get_random_spawn_point()
		resource_container.add_child(clock)

func spawn_energy_orbs():
	var count = randi_range(1, 3)
	for i in count:
		if randf() > 0.4:
			var orb = ENERGY_SCENE.instantiate()
			orb.item_id = "energy_orb"
			orb.global_position = get_random_spawn_point()
			resource_container.add_child(orb)

func spawn_enemies():
	var count := randi_range(1, 3)
	for i in count:
		if randf() < 0.7:  # 70% chance to spawn per slot
			var enemy = ENEMY_SCENE.instantiate()
			enemy.global_position = get_random_spawn_point()
			enemy_container.add_child(enemy)

func spawn_walls():
	var tile_size := 16
	var h_tiles := int(room_size.x / tile_size)
	var v_tiles := int(room_size.y / tile_size)

	var exit_directions := connected_neighbors.map(get_direction_to)

	for i in h_tiles:
		var x = i * tile_size
		# Top wall (skip if "up" exit)
		if not "up" in exit_directions or abs(x - room_size.x/2) > tile_size:
			add_wall(Vector2(x, 0))

		# Bottom wall (skip if "down" exit)
		if not "down" in exit_directions or abs(x - room_size.x/2) > tile_size:
			add_wall(Vector2(x, room_size.y - tile_size))

	for j in v_tiles:
		var y = j * tile_size
		# Left wall (skip if "left" exit)
		if not "left" in exit_directions or abs(y - room_size.y/2) > tile_size:
			add_wall(Vector2(0, y))

		# Right wall (skip if "right" exit)
		if not "right" in exit_directions or abs(y - room_size.y/2) > tile_size:
			add_wall(Vector2(room_size.x - tile_size, y))

func update_debug_label():
	if debug_label and debug_label is Label:
		debug_label.text = "Room: %s" % str(room_coords)

# === Helpers ===

func get_direction_to(neighbor: Vector2i) -> String:
	var delta = neighbor - room_coords
	if delta == Vector2i(0, -1): return "up"
	if delta == Vector2i(0, 1): return "down"
	if delta == Vector2i(-1, 0): return "left"
	if delta == Vector2i(1, 0): return "right"
	return ""

func get_exit_position(direction: String) -> Vector2:
	match direction:
		"up": return Vector2(room_size.x / 2, 0)
		"down": return Vector2(room_size.x / 2, room_size.y)
		"left": return Vector2(0, room_size.y / 2)
		"right": return Vector2(room_size.x, room_size.y / 2)
		_: return room_size / 2

func get_random_spawn_point(max_attempts: int = 20) -> Vector2:
	var grid_size := 16
	var margin := 24

	for i in max_attempts:
		var gx = int(round(randf_range(margin, room_size.x - margin) / grid_size)) * grid_size
		var gy = int(round(randf_range(margin, room_size.y - margin) / grid_size)) * grid_size
		var pos = Vector2(gx, gy)

		if not occupied_positions.has(pos):
			occupied_positions[pos] = true
			return pos

	# Fallback: pick any grid-aligned position even if overlapping
	var fallback = Vector2(
		int(round(randf_range(margin, room_size.x - margin) / grid_size)) * grid_size,
		int(round(randf_range(margin, room_size.y - margin) / grid_size)) * grid_size
	)
	return fallback

func add_wall(pos: Vector2):
	var wall = WALL_SCENE.instantiate()
	wall.position = pos
	wall_container.add_child(wall)
