extends CharacterBody2D

@export var gravity_comp: GravityComponent
@export var movement_comp: MovementComponent
@export var jump_comp: JumpComponent
@export var dash_comp: DashComponent
@export var ai_comp: AIComponent  # Patrol/chase logic here

func _physics_process(delta):
	gravity_comp.handle_gravity(self, delta)
	ai_comp.update_ai(self, delta)  # Sets direction/input for movement
	movement_comp.handle_horizontal_movement(self, ai_comp.get_ai_direction())
	if ai_comp.want_jump:
		jump_comp.handle_jump(self, true, Input.is_action_pressed("jump"), delta)  # Fake input
	move_and_slide()
