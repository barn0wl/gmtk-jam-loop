extends Area2D

@export var time_penalty: float = 5.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$Sprite2D.modulate = Color.RED  # Optional: visual cue
	add_to_group("enemy")

func _on_body_entered(body: Node):
	if not body.is_in_group("player"):
		return

	if body.has_method("check_if_dashing") and body.check_if_dashing():
		# Dash hit → kill
		print("Enemy killed by dash!")
		queue_free()
	else:
		# Touch without dash → time penalty
		print("Player touched enemy: -", time_penalty, " seconds")
		TimeManager.reduce_time(time_penalty)
