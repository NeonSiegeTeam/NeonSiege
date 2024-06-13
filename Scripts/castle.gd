class_name Castle extends Node3D

var health : int 
var max_health : int

signal on_castle_destroyed

func _ready():
	for brick : Brick in get_children():
		max_health += Brick.max_health
		health = max_health
		brick.on_damage.connect(on_brick_damage)

func on_brick_damage(damage : int):
	health -= damage
	if health/max_health < 0.2:
		on_castle_destroyed.emit()

