class_name AttackComponent
extends Node

@export_group("Combo Settings")
@export var combo_reset_time: float = 1.2
@export var combo_buffer_time: float = 0.15
@export var attack_cooldown: float = 0
@export var hitbox_node: Area2D
@export_group("Hitbox")
@export var attack_hitbox: Area2D              # Drag AttackHitbox here!
@export var damage_amount: int = 25            # Damage per hit
@export var knockback_force: float = 400.0     # Push enemies away
@export var hitstop_duration: float = 0.08     # Screen freeze on hit (metroidvania polish)
@export var cancel_frame: int = 2

var current_combo: int = 0
var last_attack_time: float = 0.0
var next_attack_queued: bool = false
var combo_buffer_timer: float = 0.0
var hit_objects: Array[Node2D] = []            # Track hit enemies (no double-hits)

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

func is_attacking() -> bool:
	if not sprite or not sprite.is_playing():
		return false
	var anim = sprite.animation
	return anim in ["attack1", "attack2", "attack3", "crouch_attack"]

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_hitbox_body_entered)

func handle_attack(want_to_attack: bool, delta: float) -> void:
	last_attack_time += delta
	combo_buffer_timer -= delta

	var is_attacking = sprite.is_playing() and sprite.animation.begins_with("attack")
	if not is_attacking and last_attack_time > combo_reset_time and current_combo != 0:
		current_combo = 0
		next_attack_queued = false
		combo_buffer_timer = 0.0
		_deactivate_hitbox()  # Clean up

	if want_to_attack and sprite.frame > cancel_frame:
		if (current_combo):
			
			sprite.stop()
			start_attack(2)
			combo_buffer_timer = 0.0
			current_combo = 0
		else:
			sprite.stop()
			start_attack(1)
	elif want_to_attack:
		start_attack(1)
		#elif is_attacking and current_combo < 2:
		#	next_attack_queued = true
		#	print("queue next attack")
		#	print(combo_buffer_timer)
		#elif not is_attacking and last_attack_time >= attack_cooldown:
		#	start_attack(1)
		#	print("start new combo")

func start_attack(combo_level: int) -> void:
	current_combo = combo_level
	var anim_name = "attack" + str(combo_level)
	sprite.play(anim_name)
	last_attack_time = 0.0
	combo_buffer_timer = 0.0
	hit_objects.clear()  # Reset hits for this attack
	_activate_hitbox()   # Enable hitbox

func _activate_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = true

func _deactivate_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = false
		hit_objects.clear()

func _on_animation_finished():
	var anim = sprite.animation
	if anim.begins_with("attack"):
		if next_attack_queued and current_combo < 3:
			next_attack_queued = false
			start_attack(current_combo + 1)
		else:
			combo_buffer_timer = combo_buffer_time
			_deactivate_hitbox()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  # Enemy has Damageable script
		if body in hit_objects: return  # Already hit this attack
		
		hit_objects.append(body)
		body.take_damage(damage_amount, get_knockback_direction(body))
		
		# Hitstop (screen freeze polish)
		_apply_hitstop(hitstop_duration)

func get_knockback_direction(enemy: Node2D) -> Vector2:
	var player_pos = get_parent().global_position
	var enemy_pos = enemy.global_position
	return (enemy_pos - player_pos).normalized()

func _apply_hitstop(duration: float) -> void:
	# Simple screen freeze: tween time_scale
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 0.01, 0.01)  # Instant freeze
	tween.tween_property(Engine, "time_scale", 1.0, duration - 0.01)
