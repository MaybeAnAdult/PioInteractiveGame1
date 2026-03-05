class_name GravityComponent
extends Node


@export_subgroup("Settings")
@export var gravity: float = 900.0
@export var dash_component: DashComponent

var is_falling: bool = false

func handle_gravity(body: CharacterBody2D, delta: float) -> void:
	var dash = get_parent().get_node("dash") as DashComponent
	if dash and dash.is_dashing and dash.disable_gravity_during_dash:
		is_falling = false
		return  # Gravity OFF during dash
