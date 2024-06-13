class_name Brick extends RigidBody3D

signal on_damage(int)

const max_health : int = 5
@export var health : int = max_health :
	set(value):
		health = value
		health_feedback.set_shader_parameter("Health",value/max_health)

var health_feedback : ShaderMaterial

func _on_body_entered(body):
	if body is Bullet:
		health -= Bullet.damage
		on_damage.emit(Bullet.damage)
