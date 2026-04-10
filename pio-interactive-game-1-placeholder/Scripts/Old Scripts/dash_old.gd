class_name DashComponent_old
extends Node

@export var dash_distance: float = 100
@export var max_dashes: int = 1
@export var dash_cooldown: float = 0.5  # Seconds before you can dash again

var dashes_available: int = 1
var cooldown_timer: float = 0.0
var last_dash_was_grounded: bool = false

func handle_dash(body: CharacterBody2D, want_to_dash: bool, direction: Vector2, sprite: AnimatedSprite2D, delta: float) -> void:
	# Count down cooldown timer
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	# Can only dash if: cooldown is done AND have dashes available
	if want_to_dash and dashes_available > 0 and cooldown_timer <= 0:
		var is_grounded = body.is_on_floor()
		
		# Prevent double ground dash: can't dash on ground if last dash was also on ground
		if is_grounded and last_dash_was_grounded:
			return
		
		var dash_dir = direction
		
		# If no input direction, dash in facing direction
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2(1 if not sprite.flip_h else -1, 0)
		else:
			# Normalize so diagonal dashes aren't longer
			dash_dir = dash_dir.normalized()
		
		# Calculate target position
		var target_offset = dash_dir * dash_distance
		
		# Try moving in small steps to find collision
		var steps = 20
		var step_size = dash_distance / steps
		var final_position = body.position
		
		for i in range(steps):
			var test_offset = dash_dir * step_size * (i + 1)
			var collision = body.test_move(body.global_transform, test_offset)
			
			if collision:
				break
			else:
				final_position = body.position + test_offset
		
		# Apply the dash
		body.position = final_position
		dashes_available -= 1
		cooldown_timer = dash_cooldown  # Start cooldown
		last_dash_was_grounded = is_grounded  # Remember if this was a ground dash

func reset_dashes() -> void:
	dashes_available = max_dashes
	last_dash_was_grounded = false  # Reset when landing
