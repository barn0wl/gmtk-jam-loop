extends Node2D

func _ready():
	var spawn = $World/PlayerSpawn
	var player = $World/Player
	player.global_position = spawn.global_position
