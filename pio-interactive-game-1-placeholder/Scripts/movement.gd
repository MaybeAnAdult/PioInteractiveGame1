# FULL UPDATED MovementComponent.gd (replace entire file)
class_name MovementComponent
extends Node

@export var can_move: bool = true
var is_crouching: bool = false

@export_subgroup("Components")
@export var attack_component: AttackComponent
@export var dash_component: DashComponent
@export var player_camera: PlayerCameraComponent

@export_subgroup("Settings")
@export var speed: float = 250
@export var acceleration := 0.1
@export var friction := 0.5

@export_subgroup("Crouch Settings")
@export var time_until_pan: float = 1
@export var max_pan: int = 150
@export var pan_speed: float = 0.6
var time_crouched: float = 0

@export_subgroup("Attack Lock")
@export var attack_speed_mult: float = 0.0  # Tune: 0.2 = crawl, 0.5 = brisk
@export var attack_friction: float = 0.85   # High = smooth forward slide


func handle_horizontal_movement(body: CharacterBody2D, direction: float, delta) -> void:
	# No control during dash
	
	is_crouching = Input.is_action_pressed("move_down") and get_parent().is_on_floor()
	
	if is_crouching:
		time_crouched += delta
		if time_crouched > time_until_pan:
			var target_cam_offset = min((time_crouched-time_until_pan)*60*pan_speed, max_pan)
			player_camera.camera_offset = Vector2(0,target_cam_offset)
	else:
		player_camera.camera_offset = Vector2.ZERO
		time_crouched = 0
		
	if dash_component and dash_component.is_currently_dashing():
		return
	
	# ATTACK LOCK: Slow slide in facing direction ONLY (no turning!)
	#if attack_component and attack_component.is_attacking():
	#	var sprite = body.get_node("AnimatedSprite2D")
	#	var facing_dir = -1.0 if sprite.flip_h else 1.0
	#	
	#	# Heavy friction → natural slowdown + forward commitment
	#	body.velocity.x *= attack_friction
	#	
	#	# Accelerate ONLY forward (input ignored for turning)
	#	var target_speed = speed * attack_speed_mult
	#	if abs(body.velocity.x) < target_speed:
	#		body.velocity.x += facing_dir * target_speed * acceleration
	#	return
	
	# NORMAL movement (your original logic)
	if can_move:
		if abs(body.velocity.x) < speed:
			body.velocity.x += direction * speed * acceleration
		if direction != 0 and attack_component.is_attacking():
			attack_component.stop_attack()
	else:
		_apply_friction(body, attack_friction, delta)
		can_move = attack_component.attack_cancel_test(true)
			
	if direction == 0 or sign(direction) != sign(body.velocity.x):
		_apply_friction(body, friction, delta)
			
	if abs(body.velocity.x) > speed:
		body.velocity.x = speed * sign(direction)
		
func _apply_friction(body, applied_friction, delta) -> void:
	var tps = Engine.physics_ticks_per_second
	#print(delta," * ",tps,"[",(delta*tps)/(tps/60),"]")
	body.velocity.x *= applied_friction
