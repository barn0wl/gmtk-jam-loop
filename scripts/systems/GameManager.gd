extends Node

enum GameState { START, PLAYING, NIGHT, GAME_OVER }

var current_state: GameState = GameState.START
var player: Node = null
var player_is_in_camp: bool = false

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

	# Find RoomManager in current scene
	var current_scene = get_tree().current_scene
	var room_manager = current_scene.get_node("RoomManager")
	var world = current_scene.get_node("World")

	world.add_child(player)

	# Center player in room (0, 0)
	var room_coords = Vector2(0, 0)
	var offset = room_manager.room_size / 2
	player.global_position = room_coords * room_manager.room_size + offset

func on_nightfall():
	current_state = GameState.NIGHT
	if player_is_in_camp:
		print("Player survived the night.")
		start_new_loop()
	else:
		print("Player died outside the camp.")
		game_over()

func game_over():
	current_state = GameState.GAME_OVER
	TimeManager.stop_timer()
	player.queue_free()
	# Trigger game over UI or fade screen
	print("Game Over")

func start_new_loop():
	# (Stretch) Keep items at camp, respawn enemies/resources
	TimeManager.reset_timer()
	spawn_player()
	current_state = GameState.PLAYING

func set_player_in_camp(is_in_camp: bool):
	player_is_in_camp = is_in_camp
