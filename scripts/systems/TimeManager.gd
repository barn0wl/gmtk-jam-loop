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
		time_left = 0
		running = false
		emit_signal("nightfall")

func update_ui():
	var ui = get_node_or_null("/root/Main/UI/TimerDisplay")
	if ui:
		ui.text = "Time: %.1f" % time_left

# Add or subtract time
func modify_time(amount: float):
	time_left = clamp(time_left + amount, 0.0, day_duration)
	update_ui()
	if time_left <= 0 and running:
		running = false
		emit_signal("nightfall")
	print("Time adjusted by %.1f seconds. New time: %.1f" % [amount, time_left])

# quick wrapper methods for clarity
func add_time(seconds: float):
	modify_time(abs(seconds))  # always positive

func reduce_time(seconds: float):
	modify_time(-abs(seconds))  # always negative
