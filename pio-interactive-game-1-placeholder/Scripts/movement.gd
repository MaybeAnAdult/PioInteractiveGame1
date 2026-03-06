# FULL UPDATED MovementComponent.gd (replace entire file)
class_name MovementComponent
extends Node

@export_subgroup("Settings")
@export var speed: float = 400
@export var acceleration := 0.02
@export var friction := 0.9

@export_subgroup("Attack Lock")
@export var attack_component: AttackComponent
@export var dash_component: DashComponent
@export var attack_speed_mult: float = 0.3  # Tune: 0.2 = crawl, 0.5 = brisk
@export var attack_friction: float = 0.95   # High = smooth forward slide

func handle_horizontal_movement(body: CharacterBody2D, direction: float) -> void:
	# No control during dash
	if dash_component and dash_component.is_currently_dashing():
		return
	
	# ATTACK LOCK: Slow slide in facing direction ONLY (no turning!)
	if attack_component and attack_component.is_attacking():
		var sprite = body.get_node("AnimatedSprite2D")
		var facing_dir = -1.0 if sprite.flip_h else 1.0
		
		# Heavy friction → natural slowdown + forward commitment
		body.velocity.x *= attack_friction
		
		# Accelerate ONLY forward (input ignored for turning)
		var target_speed = speed * attack_speed_mult
		if abs(body.velocity.x) < target_speed:
			body.velocity.x += facing_dir * target_speed * acceleration
		return
	
	# NORMAL movement (your original logic)
	if direction == 0 or sign(direction) != sign(body.velocity.x):
		body.velocity.x *= friction
	
	if abs(body.velocity.x) < speed:
		body.velocity.x += direction * speed * acceleration
	
	if abs(body.velocity.x) > speed:
		body.velocity.x *= friction
