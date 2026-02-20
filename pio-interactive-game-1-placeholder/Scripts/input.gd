class_name InputComponent
extends Node


var input_horizontal: float = 0.0
var input_vertical: float = 0.0

func get_horizontal() -> float:
	return Input.get_axis("move_left", "move_right")

func get_vertical() -> float:
	return Input.get_axis("move_down", "move_up")

func get_jump_input() -> bool:
	return Input.is_action_just_pressed("jump")

func get_dash_input() -> bool:
	return Input.is_action_just_pressed("dash")
