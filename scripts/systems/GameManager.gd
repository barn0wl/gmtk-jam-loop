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

	var current_scene = get_tree().current_scene
	var world = current_scene.get_node("World")
	var spawn = world.get_node("PlayerSpawn")

	player.global_position = spawn.global_position
	world.add_child(player)

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
