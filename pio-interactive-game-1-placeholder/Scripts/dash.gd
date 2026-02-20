class_name DashComponent
extends Node

@export var dash_distance: float = 100  # How far to teleport
@export var max_dashes: int = 1
var input_component: InputComponent
var dashes_available: int = 1
var want_dash = Input.is_action_just_pressed("dash")
var dash_direction = Vector2(input_component.get_horizontal, input_component.get_vertical)

func handle_dash(body: CharacterBody2D, want_to_dash: bool, direction: Vector2, sprite: AnimatedSprite2D) -> void:
	if want_to_dash and dashes_available > 0:
		var dash_dir = direction
		
		# If no input direction, dash in facing direction
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2(1 if not sprite.flip_h else -1, 0)
		else:
			# Normalize so diagonal dashes aren't longer
			dash_dir = dash_dir.normalized()
		
		# Teleport the position
		body.position += dash_dir * dash_distance
		dashes_available -= 1

func reset_dashes() -> void:
	dashes_available = max_dashes
