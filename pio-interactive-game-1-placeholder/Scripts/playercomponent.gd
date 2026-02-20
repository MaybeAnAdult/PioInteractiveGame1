extends CharacterBody2D


@export_subgroup("Nodes")
@export var input_component: InputComponent
@export var gravity_component: GravityComponent
@export var movement_component: MovementComponent
@export var jump_component: JumpComponent
@export var animation_component: AnimationComponent
@export var dash_component: DashComponent

func _physics_process(delta: float) -> void:
	gravity_component.handle_gravity(self, delta)
	movement_component.handle_horizontal_movement(self, input_component.get_horizontal())
	jump_component.handle_jump(self, input_component.get_jump_input())
	animation_component.update_animation(input_component.get_horizontal(),
	jump_component.is_jumping,
	gravity_component.in_air)
	dash_component.handle_dash(self, want_dash, dash_direction, $AnimatedSprite2D)
	move_and_slide()
#print input
