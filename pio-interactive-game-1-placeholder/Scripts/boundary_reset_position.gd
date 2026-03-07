extends Area2D
func _ready() -> void:
	print("South Boundary Ready")
	pass

func _on_body_entered(body) -> void:
	print("OUT OF BOUNDS! ",body," | ", body.get_groups)
	if body.is_in_group("Player"):
		body.global_position = $"TeleportPosition".global_position
		print("Resetting Position : ", $"TeleportPosition".global_position)
