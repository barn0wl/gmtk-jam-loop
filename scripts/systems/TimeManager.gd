extends Node

signal nightfall

@export var day_duration: float = 180.0  # 3 minutes
var time_left: float = 0.0
var running: bool = false

func start_timer():
	time_left = day_duration
	running = true

func stop_timer():
	running = false

func reset_timer():
	start_timer()

func _process(delta: float):
	if not running:
		return

	time_left -= delta
	update_ui()

	if time_left <= 0:
		running = false
		emit_signal("nightfall")

func update_ui():
	# Optional: update timer display label
	var ui = get_node_or_null("/root/Main/UI/TimerDisplay")
	if ui:
		ui.text = "Time: %.1f" % time_left
