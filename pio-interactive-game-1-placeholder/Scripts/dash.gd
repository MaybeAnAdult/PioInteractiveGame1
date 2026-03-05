class_name DashComponent
extends Node

@export_subgroup("Dash Settings")
@export var dash_speed_horizontal: float = 1400.0   # Strong horizontal traversal
@export var dash_speed_vertical: float = 400.0      # Nerfed vertical (prevents moon jumps)
@export var max_dashes: int = 1                     # Air dashes before ground reset
@export var dash_duration: float = 0.15             # Burst "lock" time (ignores other inputs)
@export var dash_cooldown: float = 0.6              # Recharge time
@export var disable_gravity_during_dash: bool = true # Toggle for gravity shutdown (checked by gravity.gd)

var dashes_available: int = 1
var cooldown_timer: float = 0.0
var dash_duration_timer: float = 0.0
var is_dashing: bool = false                        # Public: movement/gravity/animate check this!

func handle_dash(body: CharacterBody2D, want_to_dash: bool, direction: Vector2, sprite: AnimatedSprite2D, delta: float) -> void:
	# Countdown cooldown
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	# Manage ongoing dash
	if is_dashing:
		dash_duration_timer -= delta
		if dash_duration_timer <= 0:
			is_dashing = false
			# Optional polish: dampen residual upward momentum
			# if body.velocity.y < 0:
			#     body.velocity.y *= 0.5
		return  # Ignore inputs during dash
	
	# Start new dash
	if want_to_dash and cooldown_timer <= 0 and dashes_available > 0:
		var dash_dir = direction
		if dash_dir == Vector2.ZERO:
			# Default to facing direction
			dash_dir = Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT
		else:
			dash_dir = dash_dir.normalized()
		
		# Scale speed: horizontal strong, vertical controlled
		var effective_speed = dash_speed_horizontal
		if abs(dash_dir.y) > abs(dash_dir.x):  # Pure/mostly vertical
			effective_speed = dash_speed_vertical
		
		# Apply clean velocity burst
		body.velocity = dash_dir * effective_speed
		
		# Lock in
		is_dashing = true
		dash_duration_timer = dash_duration
		cooldown_timer = dash_cooldown
		dashes_available -= 1

func reset_dashes() -> void:
	dashes_available = max_dashes

# Public getter (use if you prefer over direct is_dashing access)
func is_currently_dashing() -> bool:
	return is_dashing
