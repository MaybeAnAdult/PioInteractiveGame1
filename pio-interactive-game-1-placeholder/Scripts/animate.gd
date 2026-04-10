class_name AnimationComponent
extends Node

@export_subgroup("Nodes")
@export var sprite: AnimatedSprite2D

@export_subgroup("References")
@export var dash_component: DashComponent
@export var attack_component: AttackComponent
@export var move_component: MovementComponent

func _ready() -> void:
	# Connect signals to handle the "Strong Attack" movement lock automatically
	if sprite:
		if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)

## SAFE PLAY FUNCTION: Prevents crashes if an animation is missing
func safe_play(anim_name: String) -> void:
	if not sprite: return
	
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		# Fallback: if 'attack3' is missing, try generic 'attack', else 'idle'
		if "attack" in anim_name and sprite.sprite_frames.has_animation("attack"):
			sprite.play("attack")
		else:
			sprite.play(sprite.sprite_frames.get_animation_names()[0]) # Plays first available (usually idle)

func handle_horizontal_flip(move_direction: float) -> void:
	if not sprite: return
	if move_direction > 0:
		sprite.flip_h = false
	elif move_direction < 0:
		sprite.flip_h = true

## Re-added to fix the "Nonexistent function" error in player.gd
func reset_rotation() -> void:
	if sprite:
		sprite.rotation = 0

func update_animation(move_direction: float, is_jumping: bool, is_falling: bool, velocity: Vector2) -> void:
	# Safety check to prevent "null value" errors
	if not sprite: return

	# Flip ONLY if NOT dashing or attacking
	if not (dash_component and dash_component.is_currently_dashing()) \
		and not (attack_component and attack_component.is_attacking()):
		handle_horizontal_flip(move_direction)
		
	# HIGHEST PRIORITY: Dash
	if dash_component and dash_component.is_currently_dashing():
		# Only rotate if we have velocity
		if velocity.y != 0 or velocity.x != 0:
			sprite.rotation = deg_to_rad(wrapf(rad_to_deg(velocity.angle()), -90, 90))
		safe_play("dash")
		return
	
	# HIGH PRIORITY: Attacks (Don't interrupt)
	if sprite.is_playing() and sprite.animation in ["attack1", "attack2", "attack3"]:
		# Movement Lock logic for the Strong Attack
		if sprite.animation == "attack3" and move_component:
			move_component.can_move = false
		return
	
	# Reset rotation once dashing stops
	reset_rotation()

	# Jump/Fall
	if is_jumping:
		safe_play("jump")
		return
	if is_falling:
		safe_play("fall")
		return
	
	# Crouch Logic
	if move_component and move_component.is_crouching:
		if sprite.animation != "crouch":
			safe_play("crouch")
		return
	
	# Transition from Crouch to Idle
	if move_component and not move_component.is_crouching and sprite.animation == "crouch":
		if sprite.sprite_frames.has_animation("crouch->idle"):
			safe_play("crouch->idle")
		else:
			safe_play("idle")
		return

	# Ground movement
	if move_direction != 0:
		# Use velocity to determine walk speed/animation
		safe_play("walk")
	else:
		safe_play("idle")

func _on_animation_finished() -> void:
	if not sprite: return
	
	# Automatically unlock movement when the Strong Attack (attack3) ends
	if sprite.animation == "attack3":
		if move_component:
			move_component.can_move = true
