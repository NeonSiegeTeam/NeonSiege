class_name NeonEngine extends CharacterBody3D

@export var orbit_offset : float = 12
@export var damping_factor : float = 0.98

@onready var left_propulsor : GPUParticles3D = $LeftPropulsor
@onready var right_propulsor : GPUParticles3D = $RightPropulsor

var pos : float = 0
var speed : float = 0
var acceleration : float = 0
var player_acceleration_rate : float = (PI * 2) / 2
var change_dir_rate = 2

func _physics_process(delta):
	var input = Input.get_axis("move_left", "move_right")
	
	left_propulsor.emitting = input > 0
	right_propulsor.emitting = input < 0
	
	acceleration = \
		input * player_acceleration_rate \
		+ -speed * damping_factor
	
	speed += acceleration * delta
	pos += speed * delta

	position = Vector3(sin(pos),0,cos(pos)) * orbit_offset + Vector3.UP
	rotation.y = pos
