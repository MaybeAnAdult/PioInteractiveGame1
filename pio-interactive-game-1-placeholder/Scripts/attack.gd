class_name AttackComponent
extends Node

@export_group("Combo Settings")
@export var combo_reset_time: float = 1.2      # Longer than any attack animation
@export var combo_buffer_time: float = 0.15    # Grace period after attack to chain
@export var attack_cooldown: float = 0.2       # Minimum time between attack starts

var current_combo: int = 0                      # 1-3
var last_attack_time: float = 0.0
var next_attack_queued: bool = false
var combo_buffer_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var animation_component: AnimationComponent = $"../animate"

func _ready():
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func handle_attack(want_to_attack: bool, delta: float) -> void:
	# Update timers
	last_attack_time += delta
	combo_buffer_timer -= delta

	# Only reset combo if NOT currently playing an attack animation
	var is_attacking = sprite.is_playing() and sprite.animation in ["attack1", "attack2", "attack3"]
	if not is_attacking and last_attack_time > combo_reset_time and current_combo != 0:
		current_combo = 0
		next_attack_queued = false
		combo_buffer_timer = 0.0

	if want_to_attack:
		# Case 1: Currently playing an attack → queue next if possible
		if is_attacking and current_combo < 3:
			next_attack_queued = true
		# Case 2: Within buffer window after attack finished → continue combo
		elif combo_buffer_timer > 0 and current_combo < 3:
			start_attack(current_combo + 1)
			combo_buffer_timer = 0.0
		# Case 3: Idle, ready to start new combo
		elif not is_attacking and last_attack_time >= attack_cooldown:
			start_attack(1)

func start_attack(combo_level: int) -> void:
	current_combo = combo_level
	var anim_name = "attack" + str(combo_level)
	sprite.play(anim_name)
	last_attack_time = 0.0
	combo_buffer_timer = 0.0

func _on_animation_finished():
	var anim = sprite.animation
	if anim in ["attack1", "attack2", "attack3"]:
		if next_attack_queued and current_combo < 3:
			next_attack_queued = false
			start_attack(current_combo + 1)
		else:
			# Start buffer window for chaining
			combo_buffer_timer = combo_buffer_time
