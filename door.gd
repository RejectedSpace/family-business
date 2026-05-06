extends Node3D

class_name Door

@export var direction: String

@onready var nav = $NavigationRegion3D
@onready var blocker = $Blocker

func _ready() -> void:
	if nav.navigation_mesh.get_reference_count() > 1:
		nav.navigation_mesh = nav.navigation_mesh.duplicate()

func set_enabled(value: bool) -> void:
	nav.set_enabled(value)
	nav.set_visible(value)
	blocker.set_use_collision(not value)
	blocker.set_visible(not value)

func is_enabled() -> bool:
	return nav.is_enabled()

func get_direction() -> float:
	match direction[0].to_lower():
		"n":
			return 0.0
		"e":
			return -PI / 2
		"s":
			return -PI
		"w":
			return PI / 2
	return -1
