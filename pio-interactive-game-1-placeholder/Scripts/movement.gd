class_name MovementComponent
extends Node

@export_subgroup("Settings")
@export var speed: float = 400
@export var acceleration := 0.02
@export var friction := 0.9  # Changed: higher = less friction (0.9 means keep 90% of speed)

func handle_horizontal_movement(body: CharacterBody2D, direction: float) -> void:
	if get_parent().get_node("dash").is_dashing:
		return  # No air control during dash
# Apply friction when no input OR changing direction
	if direction == 0 or sign(direction) != sign(body.velocity.x):
		body.velocity.x *= friction
	
# Accelerate up to max speed
	if abs(body.velocity.x) < speed:
		body.velocity.x += direction * speed * acceleration
#Return to speed after changing
	if abs(body.velocity.x) > speed:
		body.velocity.x = body.velocity.x * friction
