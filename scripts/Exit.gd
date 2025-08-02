extends Area2D

@export_enum("up", "down", "left", "right") var direction: String = "right"
var _activated = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	print("Player triggered exit:", direction, " | Already activated:", _activated)
	if _activated: return
	if body.is_in_group("player"):
		_activated = true
		var room_manager = find_room_manager()
		if room_manager:
			room_manager.move_to_room(direction)
		else:
			push_warning("RoomManager not found in Exit!")

func find_room_manager() -> Node:
	var current = get_parent()
	while current:
		if current.has_method("move_to_room"):
			return current
		current = current.get_parent()
	return null

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_activated = false  # Reset after they fully exit
