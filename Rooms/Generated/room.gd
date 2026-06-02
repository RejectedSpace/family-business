extends Node3D

class_name Room

@export var size: Vector3

@onready var doors: Node3D = $Doors
@onready var nav: NavigationRegion3D = $NavigationRegion3D
@onready var spawn_points: Node3D = $SpawnPoints

func _ready() -> void:
	assert(size.x != 0 and size.y != 0 and size.z != 0, "Room size can't be zero")
	if nav.navigation_mesh.get_reference_count() > 1:
		nav.navigation_mesh = nav.navigation_mesh.duplicate()

func get_doors() -> Array:
	return doors.get_children()

func get_single_doors() -> Array[Door]:
	var single_points: Array[Door] = []
	
	for point: Door in get_doors():
		if(point.name.begins_with("s")):
			single_points.append(point)
	
	return single_points

func get_double_doors() -> Array[Door]:
	var double_points: Array[Door] = []
	
	for point: Door in get_doors():
		if(point.name.begins_with("d")):
			double_points.append(point)
	
	return double_points

func get_spawn_points() -> Array[Node]:
	return spawn_points.get_children()
