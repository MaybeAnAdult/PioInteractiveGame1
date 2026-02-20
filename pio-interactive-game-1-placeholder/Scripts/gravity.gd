class_name GravityComponent
extends Node


@export var gravity: float = 900.0


var in_air: bool = false

func handle_gravity(body: CharacterBody2D, delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
		in_air = true
		
		
