extends CanvasLayer

@onready var timer_label = $TimerDisplay
@onready var energy_label = $EnergyDisplay
@onready var key_label = $KeyIndicator

func _process(_delta):
	update_time()
	update_energy()
	update_key()

func update_time():
	timer_label.text = "⏱ Time: %.0f" % TimeManager.time_left

func update_energy():
	var player = GameManager.player
	if player and player.has_variable("energy"):
		energy_label.text = "⚡ Energy: %d" % int(player.energy)
	else:
		energy_label.text = "⚡ Energy: --"

func update_key():
	if GameManager.player_has_key:
		key_label.text = "🔑 Key: Yes"
	else:
		key_label.text = "🔑 Key: No"
