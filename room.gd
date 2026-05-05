extends Node3D

class_name Room

@export var size: Vector3

@onready var door_points = $DoorPoints
@onready var nav = $NavigationRegion3D

func _ready() -> void:
	if nav.navigation_mesh.get_reference_count() > 1:
		nav.navigation_mesh = nav.navigation_mesh.duplicate()

func get_door_points() -> Array[Node]:
	return door_points.get_children()

func get_single_door_points() -> Array:
	var single_points = []
	
	for point in get_door_points():
		if(point.name.begins_with("s")):
			single_points.append(point)
	
	return single_points

func get_double_door_points() -> Array:
	var double_points = []
	
	for point in get_door_points():
		if(point.name.begins_with("d")):
			double_points.append(point)
	
	return double_points
