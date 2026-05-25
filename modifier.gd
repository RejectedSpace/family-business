extends Node3D

class_name Modifier

@export var modifier_function_name: String
@export var val: float
@export var price: int
@export var rarity: int

func get_modifier_function() -> String:
	return modifier_function_name

func get_modifier_value() -> float:
	return val
