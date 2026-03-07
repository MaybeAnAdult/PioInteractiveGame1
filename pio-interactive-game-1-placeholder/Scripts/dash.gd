class_name DashComponent
extends Node
@export var movement_component: MovementComponent
@export var animation_component: AnimationComponent

@export_subgroup("Dash Settings")
@export var dash_distance: float = 700.0
@export var velocity_kept: float = 0.25 # % of velocity kept after dashing
@export var dash_speed_horizontal: float = 700
@export var dash_speed_vertical: float = 600.0
@export var max_dashes: int = 1
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.3
@export var disable_gravity_during_dash: bool = true

@export_subgroup("Afterimage Settings")
@export var afterimage_interval: float = 0.07      # How often to spawn a ghost (smaller = denser)
@export var afterimage_fade_time: float = 0.35     # How long each ghost takes to fade
@export var afterimage_opacity: float = 0.7        # Starting alpha of each ghost

var dashes_available: int = 1
var cooldown_timer: float = 0.0
var dash_duration_timer: float = 0.0
var afterimage_timer: float = 0.0
@export var is_dashing: bool = false

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

func _ready() -> void:
	if not sprite:
		push_error("AnimatedSprite2D not found at ../AnimatedSprite2D!")


func handle_dash(body: CharacterBody2D, want_to_dash: bool, direction: Vector2, sprite_ref: AnimatedSprite2D, delta: float) -> void:
	# Cooldown countdown
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	# Dash in progress
	if is_dashing:
		dash_duration_timer -= delta
		afterimage_timer -= delta
		
		# Spawn afterimages during dash
		if afterimage_timer <= 0:
			_spawn_afterimage()
			afterimage_timer = afterimage_interval
		
		# End dash
		if dash_duration_timer <= 0:
			is_dashing = false
			body.velocity = body.velocity*velocity_kept
			afterimage_timer = 0.0  # stop spawning
			animation_component.reset_rotation()
		
		return  # Ignore input during dash
	
	# Start new dash
	if want_to_dash and cooldown_timer <= 0 and dashes_available > 0 and movement_component.can_move:
		var dash_dir := direction
		
		# Default to facing direction if no input
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT
		else:
			dash_dir = dash_dir.normalized()
		
		# Choose speed
		var speed := dash_speed_horizontal
		if abs(dash_dir.y) > abs(dash_dir.x):
			speed = dash_speed_vertical
		
		# Apply burst
		body.velocity = dash_dir * speed
		
		# Activate
		is_dashing = true
		dash_duration_timer = dash_duration
		cooldown_timer = dash_cooldown
		dashes_available -= 1
		
		# Prepare afterimages
		afterimage_timer = 0.0  # spawn first one very soon


func _spawn_afterimage() -> void:
	if not sprite:
		return
	
	var ghost = AnimatedSprite2D.new()
	ghost.sprite_frames = sprite.sprite_frames
	ghost.animation = sprite.animation
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.rotation = sprite.rotation
	ghost.global_position = sprite.global_position
	
	#d Spawn as child of the AnimatedSprite2D → perfect local alignment, no offset
	add_child(ghost)
	
	# Optional: tiny random offset for more organic look (comment out if you want perfect overlap)
	# ghost.position += Vector2(randf_range(-3, 3), randf_range(-3, 3))
	
	ghost.modulate.a = afterimage_opacity
	
	# Fade out and remove
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, afterimage_fade_time)
	tween.tween_callback(ghost.queue_free)


func reset_dashes() -> void:
	dashes_available = max_dashes


func is_currently_dashing() -> bool:
	return is_dashing
