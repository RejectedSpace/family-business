extends Node3D

class_name Item

@export var function_name: StringName
@export var item_name: StringName
@export var price: int
@export var rarity: int

func get_function_name() -> StringName:
	return function_name

func get_item_name() -> StringName:
	return item_name

func get_price() -> int:
	return price

func get_rarity() -> int:
	return rarity
