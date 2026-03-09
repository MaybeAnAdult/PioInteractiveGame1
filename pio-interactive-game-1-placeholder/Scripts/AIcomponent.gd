class_name AIComponent
extends Node

@export_enum("Patrol", "Chase", "Jumper") var ai_type: String = "Chase"
@export var aggro_range: float = 200.0

var state: String = "idle"
var ai_direction: float = 0.0
var want_jump: bool = false

@onready var player = get_tree().get_first_node_in_group("player")

func update_ai(body: CharacterBody2D, delta: float) -> void:
	if not player: return

	var dist = body.global_position.distance_to(player.global_position)
	if dist < aggro_range:
		ai_direction = sign(player.global_position.x - body.global_position.x)
		state = "chase"
		if ai_type == "Jumper" and dist < 100:
			want_jump = true
	else:
		ai_direction = 0.0
		state = "patrol"

func get_ai_direction() -> float:
	return ai_direction
