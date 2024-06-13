class_name DesktopController extends Node3D

## rotation speed in degree per seconds
var rotation_speed : float = 30

func _process(delta):
	var input = Input.get_axis("move_left","move_right")
	rotation_degrees.y += input * delta * rotation_speed
