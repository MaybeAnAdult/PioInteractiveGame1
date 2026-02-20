class_name JumpComponent
extends Node


@export_subgroup("Settings")
@export var jump_velocity: float = -350.0
@export var jump_buffer_time := 0.1
@export var jump_buffer_counter := 0.0
@export var coyote_time := 0.15
@export var coyote_timer := 0.0
var is_jumping: bool = false


func handle_jump(body: CharacterBody2D, want_to_jump: bool) -> void:
	if want_to_jump and body.is_on_floor():
		body.velocity.y = jump_velocity

	is_jumping = body.velocity.y < 0 and not body.is_on_floor()
