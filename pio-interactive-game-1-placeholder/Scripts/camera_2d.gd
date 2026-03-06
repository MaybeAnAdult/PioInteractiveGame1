extends Camera2D
  
@onready var player = get_parent()
@export var camera_target_speed: float = 3
@export var max_camera_offset : float = 100
var camera_speed : int = 15

func _process(delta: float) -> void:
	var target_x = sign(player.velocity.x)*min(remap(abs(player.velocity.x),0,600,0,max_camera_offset/2),max_camera_offset)
	var target_y = sign(player.velocity.y)*min(remap(abs(player.velocity.y),0,600,0,max_camera_offset/2),max_camera_offset)
	var target_offset = Vector2(target_x, target_y)
	#print(target_offset)
	#print(position_smoothing_speed)
	position = position.lerp(target_offset, delta * camera_target_speed)
	position_smoothing_speed = max(15,abs(player.velocity.x)/100,abs(player.velocity.y)/100)
