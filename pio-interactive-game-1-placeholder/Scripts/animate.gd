class_name AnimationComponent
extends Node


@export_subgroup("Nodes")
@export var sprite: AnimatedSprite2D


func handle_horizontal_flip(move_direction: float) -> void:
	print("Direction:", move_direction)

	if move_direction > 0:
		sprite.flip_h = false
	elif move_direction < 0:
		sprite.flip_h = true


func update_animation(move_direction: float, is_jumping: bool, is_falling: bool):
	handle_horizontal_flip(move_direction)
	# Jump has highest priority
	if is_jumping:
		sprite.play("jump")
		return

	if is_falling:
		sprite.play("fall")
		return

	# Ground movement
	handle_horizontal_flip(move_direction)

	if move_direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
		
	print(move_direction)
