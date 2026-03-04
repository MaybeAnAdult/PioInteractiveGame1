extends CharacterBody2D
@export_subgroup("Nodes")
@export var input_component: InputComponent
@export var gravity_component: GravityComponent
@export var movement_component: MovementComponent
@export var jump_component: JumpComponent
@export var animation_component: AnimationComponent
@export var dash_component: DashComponent
@export var attack_component: AttackComponent



func _physics_process(delta: float) -> void:
	gravity_component.handle_gravity(self, delta)
	movement_component.handle_horizontal_movement(self, input_component.get_horizontal())
	jump_component.handle_jump(self, input_component.get_jump_input(), delta)
##	attack_component.handle_attack(CharacterBody2D, want_to_attack, delta)
# Get dash input and direction
	var want_dash = input_component.get_dash_input()
	var dash_direction = Vector2(input_component.get_horizontal(), input_component.get_vertical())
	dash_component.handle_dash(self, want_dash, dash_direction, $AnimatedSprite2D, delta)
	
# Reset dashes when on ground
	if is_on_floor():
		dash_component.reset_dashes()

	animation_component.update_animation(
		input_component.get_horizontal(),
		jump_component.is_jumping,
		gravity_component.is_falling
	)
	
	move_and_slide()
