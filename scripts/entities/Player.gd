extends CharacterBody2D

@export var move_speed: float = 150.0
@export var dash_speed: float = 450.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.3
@export var max_energy: int = 3
@export var energy_recharge_rate: float = 0.5  # 1 point every 0.5 sec

var energy: float = max_energy
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Recharge energy over time (if not at max)
	if energy < max_energy:
		energy += delta / energy_recharge_rate
		energy = min(energy, max_energy)

	# Handle cooldown
	if cooldown_timer > 0:
		cooldown_timer -= delta

	# Handle dash
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * dash_speed
		if dash_timer <= 0:
			is_dashing = false
			cooldown_timer = dash_cooldown
	else:
		var input_vector = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()

		velocity = input_vector * move_speed

		# Dash trigger
		if Input.is_action_just_pressed("dash") and energy >= 1 and input_vector != Vector2.ZERO and cooldown_timer <= 0:
			start_dash(input_vector)

	move_and_slide()

func start_dash(direction: Vector2):
	is_dashing = true
	dash_direction = direction.normalized()
	dash_timer = dash_duration
	energy -= 1

func recharge_energy(amount: int):
	energy = min(energy + amount, max_energy)

func check_if_dashing() -> bool:
	return is_dashing
