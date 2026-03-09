class_name AttackComponent
extends Node

@export var movement_component: MovementComponent

@export_group("Combo Settings")
@export var combo_reset_time: float = 1.2
@export var attack_cooldown: float = 0.05

@export_group("Hitbox")
@export var attack_hitbox: Area2D  # Drag your AttackHitbox Area2D here

var current_attack: int = 0          # 1 or 2 for lights, 3 for strong
var next_light: int = 1              # toggles between 1 and 2
var last_attack_time: float = 0.0
var hit_objects: Array[Node2D] = []
# Used by MovementComponent to lock movement/turning during attacks
var attack_facing_direction: float = 1.0

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
func is_attacking() -> bool:
	if not sprite or not sprite.is_playing():
		return false
	return sprite.animation in ["attack1", "attack2", "attack3", "crouch_attack"]

func get_attack_facing_dir() -> float:
	return attack_facing_direction

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_hitbox_body_entered)

func handle_attack(light_just_pressed: bool, strong_just_pressed: bool, delta: float) -> void:
	last_attack_time += delta

	# Reset combo if idle too long
	if not is_attacking() and last_attack_time > combo_reset_time and current_attack != 0:
		current_attack = 0
		next_light = 1
		_deactivate_hitbox()
		return

	# ─── STRONG ATTACK (attackstrong button) ───
	# Always starts attack3 and is uninterruptible
	if strong_just_pressed and not sprite.animation == "attack3":
		start_attack(3)
		return

	# ─── LIGHT ATTACK CHAIN (normal attack button) ───
	if light_just_pressed:
		if not is_attacking():
			# Start new light chain from idle
			start_attack(next_light)
			return

		elif current_attack in [1, 2]:
			# Alternate between 1 and 2
			var next_one = 3 - current_attack
			start_attack(next_one)
			return

func start_attack(level: int) -> void:
	current_attack = level
	var anim_name = "attack" + str(level)
	sprite.play(anim_name)

	last_attack_time = 0.0
	hit_objects.clear()
	_activate_hitbox()

	# Lock movement during any attack
	if movement_component:
		movement_component.can_move = false

	# Lock facing direction
	attack_facing_direction = 1.0 if not sprite.flip_h else -1.0

func _activate_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = true

func _deactivate_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = false
		hit_objects.clear()

func _on_animation_finished():
	if sprite.animation in ["attack1", "attack2"]:
		# Toggle for next light press
		next_light = 3 - current_attack
		_deactivate_hitbox()
		current_attack = 0

	elif sprite.animation == "attack3":
		# Strong attack finished — full reset
		next_light = 1
		_deactivate_hitbox()
		current_attack = 0

	# Re-enable movement
	if movement_component:
		movement_component.can_move = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body not in hit_objects:
		hit_objects.append(body)
		# You said you want to handle damage separately, so we just call it
		body.take_damage(25, Vector2.ZERO)  # damage amount and knockback can be handled in enemy script

# Optional helper if you ever want to force-stop an attack
func force_stop() -> void:
	sprite.stop()
	_on_animation_finished()
