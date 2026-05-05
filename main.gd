extends Node3D

var map = []
@onready var room_stash = $Rooms
const MAPSIZE = Vector3(20, 10, 20)

func _ready() -> void:
	generate()

func generate() -> void:
	for x in range(0, MAPSIZE.x):
		map.append([])
		for y in range(0, MAPSIZE.y):
			map[x].append([])
			for z in range(0, MAPSIZE.z):
				map[x][y].append(false)
	
	var main_room = room_stash.get_child(0).duplicate()
	
	var debug = 0
	main_room.rotate_y(debug)
	main_room.position = map_to_game_coords(Vector3(MAPSIZE.x / 2, 0, MAPSIZE.z / 2), debug)
	
	add_child(main_room)
	fill_map(main_room, Vector3(MAPSIZE.x / 2, 0, MAPSIZE.z / 2), debug)
	
	var door_queue = []
	var rooms = room_stash.get_children()
	door_queue.append(main_room)
	
	for room in door_queue:
		var origin = game_to_map_coords(room.position, room.rotation.y)
		for door in room.get_door_points():
			var is_single = door.name.begins_with("s")
			var new_origin = rotate_vector(find_single_door_origin(door, 1) if is_single else find_double_door_origin(door, true, 1), room.rotation.y)
			rooms.shuffle()
			for r in rooms:
				var new_room = connect_room(origin, room.rotation.y, door, r, new_origin)
				if new_room != null:
					door_queue.append(new_room)
					add_child(new_room)
					break
		door_queue.remove_at(0)
		door_queue.shuffle()

func connect_room(room_origin, room_rotation, door, room_candidate, door_origin):
	var is_single = door.name.begins_with("s")
	var doors = room_candidate.get_single_door_points() if is_single else room_candidate.get_double_door_points()
	
	doors.shuffle()
	for d in doors:
		var new_room_rotation = angle_difference(angle_difference(angle_difference(door.rotation.y, d.rotation.y), -room_rotation), -PI)
		var d_origin = rotate_vector(find_single_door_origin(d) if is_single else find_double_door_origin(d, false), new_room_rotation)
		var new_room_origin = door_origin - d_origin + room_origin
		if fill_map(room_candidate, new_room_origin, new_room_rotation):
			var new_room = room_candidate.duplicate()
			
			new_room.rotate_y(new_room_rotation)
			new_room.position = map_to_game_coords(new_room_origin, new_room_rotation)
			
			return new_room
	
	return null

func game_to_map_coords(coords, rot):
	var x_offset = 0 if is_zero_approx(rot) or is_equal_approx(rot,  PI/2) else 1
	var z_offset = 0 if is_zero_approx(rot) or is_equal_approx(rot, -PI/2) else 1
	
	return Vector3(coords.x / 64 + MAPSIZE.x / 2 - x_offset, coords.y / 64, coords.z / 64 - z_offset)

func map_to_game_coords(coords, rot):
	var x_offset = 0 if is_zero_approx(rot) or is_equal_approx(rot,  PI/2) else 1
	var z_offset = 0 if is_zero_approx(rot) or is_equal_approx(rot, -PI/2) else 1
	
	return Vector3((coords.x + x_offset - MAPSIZE.x / 2) * 64, coords.y * 64, (coords.z + z_offset) * 64)

func rotate_vector(vec: Vector3, rot: float) -> Vector3:
	var new_vec = Vector3(vec)
	
	if is_zero_approx(rot):
		return new_vec
	
	if is_equal_approx(rot, PI/2):
		new_vec.z = -vec.x
		new_vec.x =  vec.z
		return new_vec
	
	if is_equal_approx(rot, -PI/2):
		new_vec.z =  vec.x
		new_vec.x = -vec.z
		return new_vec
	
	new_vec.z = -vec.z
	new_vec.x = -vec.x
	return new_vec

func find_single_door_origin(door, distance = 0.0) -> Vector3:
	var z_facing = not is_equal_approx(door.rotation.y, PI/2) and not is_equal_approx(door.rotation.y, -PI/2)
	var pos_facing = is_zero_approx(door.rotation.y) or is_equal_approx(door.rotation.y, PI/2)
	var x_offset = -0.5 if     z_facing else distance - 1 if pos_facing else -distance
	var z_offset = -0.5 if not z_facing else distance - 1 if pos_facing else -distance
	
	return Vector3(door.position.x / 64 + x_offset, door.position.y / 64, door.position.z / 64 + z_offset)

func find_double_door_origin(door, connector: bool, distance = 0) -> Vector3:
	var z_facing = not is_equal_approx(door.rotation.y, PI/2) and not is_equal_approx(door.rotation.y, -PI/2)
	var pos_facing = is_zero_approx(door.rotation.y) or is_equal_approx(door.rotation.y, PI/2)
	var connector_offset = -1 if connector else 0
	var x_offset = connector_offset if     z_facing else distance - 1 if pos_facing else -distance
	var z_offset = connector_offset if not z_facing else distance - 1 if pos_facing else -distance
	
	return Vector3(door.position.x / 64 + x_offset, door.position.y / 64, door.position.z / 64 + z_offset)

func fill_map(room, origin, rot) -> bool:
	if origin.x < 0 or origin.x >= MAPSIZE.x or origin.y < 0 or origin.y + room.size.y >= MAPSIZE.y or origin.z < 0 or origin.z >= MAPSIZE.z:
		return false
	
	var size = rotate_vector(room.size, rot)
	
	if origin.x + size.x < 0 or origin.x + size.x >= MAPSIZE.x or origin.z + size.z < 0 or origin.z + size.z >= MAPSIZE.z:
		return false
	
	for i in range(origin.x, origin.x + size.x, 1 if size.x > 0 else -1):
		for j in range(origin.y, origin.y + size.y):
			for k in range(origin.z, origin.z + size.z, 1 if size.z > 0 else -1):
				if map[i][j][k]:
					return false
	
	for i in range(origin.x, origin.x + size.x, 1 if size.x > 0 else -1):
		for j in range(origin.y, origin.y + size.y):
			for k in range(origin.z, origin.z + size.z, 1 if size.z > 0 else -1):
				map[i][j][k] = true
	
	return true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("9"):
		$Camera3D.current = !$Camera3D.current

func _physics_process(delta: float) -> void:
	get_tree().call_group("enemies", "update_target_location", $Player.global_transform.origin)
