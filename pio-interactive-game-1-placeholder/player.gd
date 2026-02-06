extends CharacterBody2D

@export var speed := 200.0
@export var jump_force := -350.0
@export var gravity := 900.0
@export var friction := 0.8 # lower number = more friction, 0 is instant stop, 1 is no friction
@export var acceleration := 0.02 # % of speed applied each frame up to speed

var is_attacking = false

# Jump
var jump_buffer_time := 0.1
var jump_buffer_counter := 0.0
@export var coyote_time := 0.15
var coyote_timer := 0.0

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time
	
	# Jump Buffer
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_counter = jump_buffer_time
	else:
		jump_buffer_counter -= delta
	
	# Jump with buffer and coyote time
	if jump_buffer_counter > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_counter = 0
		coyote_timer = 0
	
	# Horizontal movement
	var dir = Input.get_axis("Move_Left", "Move_Right")
	#velocity.x = dir * speed
	if dir == 0 || dir != velocity.x/abs(velocity.x):
		velocity.x = velocity.x * friction
	
	if abs(velocity.x) < speed:
		velocity.x += dir * (speed * acceleration)
	
	print("Direction:",dir)
	print("Velocity:",velocity.x)
	
	move_and_slide()
	update_animation(dir)

func update_animation(dir):
	var sprite = $AnimatedSprite2D
	
	# Check if currently crouching (holding the button)
	var is_crouched = Input.is_action_pressed("Crouch") and is_on_floor()
	
	# Handle attack
	if Input.is_action_just_pressed("Attack") and not is_attacking:
		is_attacking = true
		if is_crouched:
			sprite.play("Crouch_Attack")
		else:
			sprite.play("Attack")
		return
	
	# If attacking, don't change animation
	if is_attacking:
		return
	
	# Ground animations
	if is_on_floor():
		if is_crouched:
			if sprite.animation != "Crouch":
				sprite.play("Crouch")
		elif dir == 0:
			sprite.play("Idle")
		else:
			sprite.play("Walk",abs(velocity.x)/50)
	# Air animations
	else:
		if velocity.y < 0:
			sprite.play("Jump")
		else:
			sprite.play("Fall")
	
	# Flip sprite based on direction
	if dir != 0:
		sprite.flip_h = dir < 0

func _on_animated_sprite_2d_animation_finished():
	var sprite = $AnimatedSprite2D
	
	if sprite.animation == "Attack":
		is_attacking = false
	elif sprite.animation == "Crouch_Attack":
		is_attacking = false
		# Go back to crouch pose if still holding crouch button
		if Input.is_action_pressed("Crouch") and is_on_floor():
			sprite.play("Crouch")
			sprite.frame = sprite.sprite_frames.get_frame_count("Crouch") - 1
			sprite.pause()
