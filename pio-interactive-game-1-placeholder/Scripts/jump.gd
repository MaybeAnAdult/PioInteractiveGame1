class_name JumpComponent
extends Node
@export var movement_component: MovementComponent

@export_subgroup("Jump Settings")
@export var jump_velocity: float = -350.0
@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1
@export var double_jump_grace_time: float = 0.2  # Brief window after first jump to double
@export var max_jumps: int = 50                  # 1 = normal, 2 = double jump

@export_subgroup("Polish")
@export var double_jump_particles: GPUParticles2D  # Drag particles node here (optional)
@export var double_jump_sfx: AudioStreamPlayer2D   # Higher pitch SFX (optional)



var jump_buffer_counter: float = 0.0
var coyote_timer: float = 0.0
var jumps_used: int = 0
var double_jump_grace_timer: float = 0.0
var is_jumping: bool = false

func handle_jump(body: CharacterBody2D, want_to_jump: bool, delta: float) -> void:
	# Coyote time (ground grace)
	if body.is_on_floor():
		coyote_timer = coyote_time
		jumps_used = 0  # ← Reset double jump on ground
	else:
		coyote_timer -= delta
	
	# Jump buffer
	if want_to_jump:
		jump_buffer_counter = jump_buffer_time
	else:
		jump_buffer_counter -= delta
	
	# Double jump grace (post-first-jump window)
	if double_jump_grace_timer > 0:
		double_jump_grace_timer -= delta
	
	# Perform jump
	if movement_component.can_move:
		var can_jump = jump_buffer_counter > 0 and (coyote_timer > 0 or jumps_used < max_jumps)
		if can_jump:
			body.velocity.y = jump_velocity
			jump_buffer_counter = 0
			coyote_timer = 0
			jumps_used += 1
			
			# Double jump SFX/polish (only if not first jump)
			if jumps_used > 1:
				_play_double_jump_fx()
			
			# Grace timer for smooth double jump timing
			if jumps_used == 1:
				double_jump_grace_timer = double_jump_grace_time

	is_jumping = body.velocity.y < 0 and not body.is_on_floor()

func _play_double_jump_fx() -> void:
	if double_jump_sfx:
		double_jump_sfx.play()
	if double_jump_particles:
		double_jump_particles.restart()
		double_jump_particles.emitting = true
