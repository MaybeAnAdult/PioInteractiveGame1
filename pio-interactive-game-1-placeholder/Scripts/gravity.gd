class_name GravityComponent
extends Node


@export_subgroup("Settings")
@export var gravity: float = 900.0
@export var dash_component: DashComponent

var is_falling: bool = false

func handle_gravity(body: CharacterBody2D, delta: float) -> void:
	print("gravity called | is_dashing = ", dash_component.is_dashing if dash_component else "null dash ref")
	
	if dash_component and dash_component.is_dashing and dash_component.disable_gravity_during_dash:
		is_falling = false
		print("→ gravity SKIPPED")
		return
	
	print("→ gravity APPLIED")
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	is_falling = body.velocity.y > 0 and not body.is_on_floor()
