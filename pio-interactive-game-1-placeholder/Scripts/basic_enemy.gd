#class_name Enemy
extends CharacterBody2D

@export_group("Core Stats")
@export var max_health: int = 3
@export var speed: float = 120.0
@export var acceleration: float = 800.0
@export var friction: float = 0.9
@export var gravity: float = 900.0  # Match player's gravity export
@export var sprite_frames: SpriteFrames

@export_group("Chase AI")
@export var aggro_range: float = 200.0
@export var attack_range: float = 50.0
@export var patrol_distance: float = 80.0

var health: int
var state: String = "patrol"
var direction: int = 1
var start_pos: Vector2
var knockback_vel: Vector2 = Vector2.ZERO

@onready var sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox

func _ready():
	health = max_health
	start_pos = global_position
	if sprite_frames:
		sprite.sprite_frames = sprite_frames
	add_to_group("enemies")
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta):
	# **GRAVITY: Mirror player's GravityComponent**
	if not is_on_floor():
		velocity.y += gravity * delta

	# Knockback decay
	velocity.x = move_toward(velocity.x, knockback_vel.x, speed * delta)
	knockback_vel = knockback_vel.move_toward(Vector2.ZERO, speed * 10 * delta)

	# Player detection + state switch
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < aggro_range and state != "attack":
			state = "chase"
		elif dist < attack_range:
			state = "attack"

	# AI behaviors
	match state:
		"patrol":
			_patrol()
		"chase":
			_chase()
		"attack":
			_attack()

	move_and_slide()
	_update_sprite()

func _patrol():
	velocity.x = direction * speed * 0.6
	if abs(global_position.x - start_pos.x) > patrol_distance:
		direction *= -1

func _chase():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		var dir_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = move_toward(velocity.x, dir_to_player * speed, acceleration * get_physics_process_delta_time())

func _attack():
	velocity.x = move_toward(velocity.x, 0, friction * speed * get_physics_process_delta_time())
	# Attack anim + hitbox activation here

func _update_sprite():
	if abs(velocity.x) > 10:
		sprite.play("walk")
		sprite.flip_h = velocity.x < 0
	else:
		sprite.play("idle")

func take_damage(amount: int, knockback_dir: Vector2):
	health -= amount
	knockback_vel = knockback_dir * 300
	if health <= 0:
		die()

func die():
	sprite.play("death")
	set_physics_process(false)
	await sprite.animation_finished
	queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(1, (body.global_position - global_position).normalized())
