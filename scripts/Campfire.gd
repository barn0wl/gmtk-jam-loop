extends Area2D

@export var safe_tag: String = "player"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(safe_tag):
		print("Player entered campfire")
		GameManager.set_player_in_camp(true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(safe_tag):
		print("Player left campfire")
		GameManager.set_player_in_camp(false)
