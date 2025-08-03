extends Node

enum GameState { START, PLAYING, NIGHT, GAME_OVER }

var current_state: GameState = GameState.START
var player: Node = null
var player_has_key: bool = false
var current_level: int = 1

func _ready():
	start_game()

func start_game():
	current_state = GameState.PLAYING
	TimeManager.start_timer()

	var room_manager = get_room_manager()
	room_manager.generate_new_level()  # build room graph first

	spawn_player()
	print("Game started")

func spawn_player():
	var player_scene = preload("res://scenes/Player.tscn")
	player = player_scene.instantiate()

	var room_manager = get_room_manager()
	var world = get_tree().current_scene.get_node("World")
	world.add_child(player)

	var start_coords = room_manager.special_rooms["start"]
	var offset = room_manager.get_room_center(start_coords)

	player.global_position = offset

func move_player_to_start():
	var room_manager = get_room_manager()
	var start_coords = room_manager.special_rooms["start"]
	var offset = room_manager.get_room_center(start_coords)
	player.global_position = offset

func next_level():
	print("Level Complete! Advancing to next level...")
	current_level += 1
	player_has_key = false

	var room_manager = get_room_manager()
	TimeManager.reset_timer()

	room_manager.generate_new_level()
	move_player_to_start()

func game_over():
	current_state = GameState.GAME_OVER
	TimeManager.stop_timer()
	if player:
		player.queue_free()
	print("Game Over")

func collect_key():
	player_has_key = true
	print("Key collected!")

func get_room_manager():
	var room_manager = get_tree().current_scene.get_node("RoomManager")
	if room_manager:
		return room_manager
	else:
		push_warning("RoomManager not found!")
		return null
