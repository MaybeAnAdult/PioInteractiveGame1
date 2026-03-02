class_name DashComponent
extends Node

@export var dash_distance: float = 600
@export var max_dashes: int = 1
@export var dash_cooldown: float = 0.5  # Seconds before you can dash again
@export var dash_time: float = 0.1

var dashes_available: int = 1
var cooldown_timer: float = 0.0
var last_dash_was_grounded: bool = false
var tween
var last_horizontal_dir



func handle_dash(body: CharacterBody2D, want_to_dash: bool, direction: Vector2, sprite: AnimatedSprite2D, delta: float) -> void:
	print("Direction:",direction)
	print("Dash Cooldown:",cooldown_timer,"/",dash_cooldown)
	cooldown_timer += 1*delta

	if want_to_dash && cooldown_timer >= dash_cooldown:
		cooldown_timer = 0
		if tween:
			tween.kill()
		print("DASHING")
		body.velocity.x = 0
		body.velocity.y = 0
		var tween = create_tween()
		tween.tween_property(body, "velocity:x", (dash_distance * direction[0]), dash_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT_IN)
		tween.tween_property(body, "velocity:y", (dash_distance * direction[1]), dash_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT_IN)
		
func reset_dashes() -> void:
	dashes_available = max_dashes
	last_dash_was_grounded = false  # Reset when landing
