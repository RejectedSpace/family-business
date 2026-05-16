extends Node3D

class_name Gun

@onready var hitscan = $Hitscan

@export var damage: float = 10.0

func get_hitscan() -> Node3D:
	return hitscan

func get_damage() -> float:
	return damage
