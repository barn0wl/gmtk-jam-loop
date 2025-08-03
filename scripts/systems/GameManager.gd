extends Node

enum GameState { START, PLAYING, NIGHT, GAME_OVER }

var current_state: GameState = GameState.START
var player: Node = null
var player_has_key: bool = false
var current_level: int = 1  # Optional for scaling difficulty

func _ready():
	start_game()

func start_game():
	current_state = GameState.PLAYING
	TimeManager.start_timer()
	spawn_player()
	print("Game started")

func spawn_player():
	var player_scene = preload("res://scenes/Player.tscn")
	player = player_scene.instantiate()

	var room_manager = get_room_manager()
	var current_scene = get_tree().current_scene
	var world = current_scene.get_node("World")

	world.add_child(player)

	# Center player in room (0, 0)
	var room_coords = Vector2(0, 0)
	var offset = room_manager.room_size / 2
	player.global_position = room_coords * room_manager.room_size + offset

func game_over():
	current_state = GameState.GAME_OVER
	TimeManager.stop_timer()
	if player:
		player.queue_free()
	print("Game Over")

func collect_key():
	player_has_key = true
	print("Key collected!")

func next_level():
	print("Level Complete! Advancing to next level...")

	current_level += 1
	player_has_key = false
	var room_manager = get_room_manager()

	TimeManager.reset_timer()
	room_manager.generate_new_level()
	move_player_to_start()

func move_player_to_start():
	var room_manager = get_room_manager()
	var offset = room_manager.room_size / 2
	player.global_position = Vector2.ZERO * room_manager.room_size + offset

func get_room_manager():
	# Find RoomManager in current scene
	var current_scene = get_tree().current_scene
	var room_manager = current_scene.get_node("RoomManager")
	if room_manager:
		return room_manager
	else:
		push_warning("Room manager not found in current Room")
