@abstract extends CharacterBody3D

class_name Entity

@export var base_health: float = 100.0

var health = base_health

var dead = false

func hurt(damage: float) -> void:
	health -= damage
	if not dead and health <= 0:
		die()

func die() -> void:
	dead = true
	queue_free()
