class_name AnimationComponent
extends Node

@export_subgroup("Nodes")
@export var sprite: AnimatedSprite2D
@export_subgroup("Dash Reference")  #drag Dash node here for clean access
@export var dash_component: DashComponent

func handle_horizontal_flip(move_direction: float) -> void:
	if move_direction > 0:
		sprite.flip_h = false
	elif move_direction < 0:
		sprite.flip_h = true


func update_animation(move_direction: float, is_jumping: bool, is_falling: bool):
	# Always flip based on direction (even during attacks)
	handle_horizontal_flip(move_direction)
	
# HIGHEST PRIORITY: Dash (new!)
	if dash_component and dash_component.is_currently_dashing():
		if sprite.animation != "dash":
			sprite.play("dash")
		return
	
	# HIGH PRIORITY: Attacks (don't interrupt)
	if sprite.is_playing() and sprite.animation in ["attack1", "attack2", "attack3", "crouch_attack"]:
		return
	
	# Jump
	if is_jumping:
		sprite.play("jump")
		return

	# Fall
	if is_falling:
		sprite.play("fall")
		return
	
	# Crouch (ground + down input)
	var is_crouching = Input.is_action_pressed("move_down") and get_parent().is_on_floor()
	if is_crouching:
		sprite.play("crouch")
		return

	# Ground movement
	if move_direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
