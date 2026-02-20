class_name JumpComponent
extends Node


@export_subgroup("Settings")
@export var jump_velocity: float = -350.0
@export var jump_buffer_time := 0.1
@export var coyote_time := 0.5
var jump_buffer_counter := 0.0
var coyote_timer := 0.0
var is_jumping: bool = false


func handle_jump(body: CharacterBody2D, want_to_jump: bool, delta: float) -> void:
# Handle coyote timer
	if body.is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	
# Handle jump buffer
	if want_to_jump:
		jump_buffer_counter = jump_buffer_time
	else:
		jump_buffer_counter -= delta
	
# Jump with buffer and coyote time
	if jump_buffer_counter > 0 and coyote_timer > 0:
		body.velocity.y = jump_velocity
		jump_buffer_counter = 0
		coyote_timer = 0

	is_jumping = body.velocity.y < 0 and not body.is_on_floor()
