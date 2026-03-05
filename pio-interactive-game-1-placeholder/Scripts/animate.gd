class_name AnimationComponent
extends Node

@export_subgroup("Nodes")
@export var sprite: AnimatedSprite2D

func handle_horizontal_flip(move_direction: float) -> void:
	if move_direction > 0:
		sprite.flip_h = false
	elif move_direction < 0:
		sprite.flip_h = true

func update_animation(move_direction: float, is_jumping: bool, is_falling: bool):
	# Always flip based on direction (even during attacks)
	handle_horizontal_flip(move_direction)
	
	# HIGHEST PRIORITY: Attack animations (only block if actively playing)
	if sprite.is_playing() and sprite.animation in ["attack1", "attack2", "attack3", "crouch_attack"]:
		return  # Don't interrupt a playing attack
	
	# Jump
	if is_jumping:
		sprite.play("jump")
		return

	if is_falling:
		sprite.play("fall")
		return
	
	# Crouch on ground
	var is_crouching = Input.is_action_pressed("move_down") and not is_falling and not is_jumping
	if is_crouching:
		if sprite.animation != "crouch":
			sprite.play("crouch")
		return

	# Ground movement
	if move_direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
