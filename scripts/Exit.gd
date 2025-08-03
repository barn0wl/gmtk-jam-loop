extends Area2D

@export_enum("up", "down", "left", "right") var direction: String = "right"
@export var is_final_exit: bool = false  # true = Exit that ends level

@onready var room_manager := get_tree().current_scene.get_node_or_null("RoomManager")
var _activated = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	if _activated: return
	if not body.is_in_group("player"): return

	_activated = true

	if is_final_exit:
		# Only trigger if player has key
		if GameManager.player_has_key:
			GameManager.next_level()
		else:
			print("You need the key to exit the level!")
	else:
		if room_manager:
			room_manager.move_to_room(direction)
		else:
			push_warning("RoomManager not found!")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_activated = false
