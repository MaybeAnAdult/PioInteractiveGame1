class_name AnimationComponent
extends Node

@export_subgroup("Nodes")
@export var sprite: AnimatedSprite2D
@export_subgroup("References")  #drag Dash node here for clean access
@export var dash_component: DashComponent
@export var attack_component: AttackComponent
@export var move_component: MovementComponent


func handle_horizontal_flip(move_direction: float) -> void:
	if move_direction > 0:
		sprite.flip_h = false
	elif move_direction < 0:
		sprite.flip_h = true

func reset_rotation() -> void:
	sprite.rotation = 0

func update_animation(move_direction: float, is_jumping: bool, is_falling: bool, velocity: Vector2):

	
	# Flip ONLY if NOT dashing/attacking (NO TURNING during attack!)
	if not (dash_component and dash_component.is_currently_dashing()) \
		and not (attack_component and attack_component.is_attacking()):
		handle_horizontal_flip(move_direction)
		
# HIGHEST PRIORITY: Dash (new!)
	if dash_component and dash_component.is_currently_dashing():
		if velocity[1] != 0 and velocity[0] != 0:
			sprite.rotation = deg_to_rad(wrapf(rad_to_deg(velocity.angle()), -90, 90))
			print(deg_to_rad(wrapf(rad_to_deg(velocity.angle()), -90, 90)))
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
	
	if move_component.is_crouching and sprite.animation != "crouch":
		sprite.play("crouch")
		return
	if move_component.is_crouching:
		return
	if !move_component.is_crouching and sprite.animation == "crouch":
		sprite.play("crouch->idle")

	# Ground movement
	if move_direction != 0:
		sprite.play("walk",log(abs(velocity[0])/60))
	elif sprite.animation:
		sprite.play("idle")
