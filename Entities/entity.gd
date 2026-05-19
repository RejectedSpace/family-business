@abstract extends CharacterBody3D

class_name Entity

@export var health: float = 100.0

var dead = false

func hurt(damage: float) -> void:
	health -= damage
	if not dead and health <= 0:
		die()

func die() -> void:
	dead = true
	queue_free()
