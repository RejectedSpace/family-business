extends Node3D

class_name Door

@export var direction: String

@onready var nav: NavigationRegion3D = $NavigationRegion3D
@onready var blocker: CSGBox3D = $Blocker

var single: bool

func _ready() -> void:
	single = name.begins_with("s")
	set_enabled(false)
	if nav.navigation_mesh.get_reference_count() > 1:
		nav.navigation_mesh = nav.navigation_mesh.duplicate()

func set_enabled(value: bool) -> void:
	nav.set_enabled(value)
	nav.set_visible(value)
	nav.set_use_edge_connections(value)
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

func is_single() -> bool:
	return single

func find_map_origin(distance: float = 0, connector: bool = false) -> Vector3:
	var z_facing: bool = not is_equal_approx(get_direction(), PI/2) and not is_equal_approx(get_direction(), -PI/2)
	var pos_facing: bool = is_zero_approx(get_direction()) or is_equal_approx(get_direction(), PI/2)
	var connector_offset: float = -0.5 if is_single() else -1.0 if connector == pos_facing == z_facing else 0.0
	var x_offset: float = connector_offset if     z_facing else distance - 1 if pos_facing else -distance
	var z_offset: float = connector_offset if not z_facing else distance - 1 if pos_facing else -distance
	
	return Vector3(position.x / 64 + x_offset, position.y / 64, position.z / 64 + z_offset)
