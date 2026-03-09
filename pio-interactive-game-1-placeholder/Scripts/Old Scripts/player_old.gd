extends CharacterBody2D

@export var speed := 200.0
@export var jump_force := -350.0
@export var gravity := 900.0
@export var friction := 0.95 # lower number = more friction, 0 is instant stop, 1 is no friction
@export var acceleration := 0.02 # % of speed applied each frame up to speed
@export var dash_force := 500 # 
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
	if Input.is_action_just_pressed("jump"):
		jump_buffer_counter = jump_buffer_time
	else:
		jump_buffer_counter -= delta
	
	# Jump with buffer and coyote time
	if jump_buffer_counter > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_counter = 0
		coyote_timer = 0
	
	# Horizontal movement
	var dir = Input.get_axis("move_left", "move_right",)
	#velocity.x = dir * speed
	if dir == 0 || dir != velocity.x/abs(velocity.x):
		velocity.x = velocity.x * friction
	
	if abs(velocity.x) < speed:
		velocity.x += dir * (speed * acceleration)
	#Dash in air
	var vert = Input.get_axis("move_up", "move_down",)
	var dash = false
	if Input.is_action_just_pressed("dash") and not is_on_floor():
		velocity.x += (dash_force * dir)
		velocity.y += (dash_force * vert)
	#Dash on ground
	if Input.is_action_just_pressed("dash") and is_on_floor():
		velocity.x += (dash_force * dir)
#Return to normal speed after dash
	if abs(velocity.x) > speed:
		velocity.x = velocity.x * friction

	#print("Direction:",dir)
	#print("Velocity:",velocity.x)
	
	move_and_slide()
	update_animation(dir)

func update_animation(dir):
	var sprite = $AnimatedSprite2D
	
	# Check if currently crouching (holding the button)
	var is_crouched = Input.is_action_pressed("move_down") and is_on_floor()
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		if is_crouched:
			sprite.play("crouch_attack")
		else:
			sprite.play("attack")
		return
	
	# If attacking, don't change animation
	if is_attacking:
		return
	
	# Ground animations
	if is_on_floor():
		if is_crouched:
			if sprite.animation != "crouch":
				sprite.play("crouch")
		elif dir == 0:
			sprite.play("idle")
		else:
			sprite.play("walk",abs(velocity.x)/50)
	# Air animations
	else:
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	
	# Flip sprite based on direction
	if dir != 0:
		sprite.flip_h = dir < 0

func _on_animated_sprite_2d_animation_finished():
	var sprite = $AnimatedSprite2D
	
	if sprite.animation == "attack":
		is_attacking = false
	elif sprite.animation == "crouch_attack":
		is_attacking = false
		# Go back to crouch pose if still holding crouch button
		if Input.is_action_pressed("crouch") and is_on_floor():
			sprite.play("crouch")
			sprite.frame = sprite.sprite_frames.get_frame_count("crouch") - 1
			sprite.pause()
