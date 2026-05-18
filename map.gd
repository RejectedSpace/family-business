extends Node3D

@export var MAPSIZE: Vector3 = Vector3(10, 3, 20)

@onready var room_stash: Array = $Rooms.get_children()
@onready var timer: Timer = $Timer
@onready var main_room: Room = $MainRoom

var map_memory: Array = []
var room_queue: Array[Room] = []
var door_dict: Dictionary = {}

var enemies: int = 0

var enemy: PackedScene = preload("res://enemy.tscn")

func generate(time: float = 0.0) -> void:
	for x: int in range(0, MAPSIZE.x):
		map_memory.append([])
		for y: int in range(0, MAPSIZE.y):
			map_memory[x].append([])
			for z: int in range(0, MAPSIZE.z):
				map_memory[x][y].append(false)
	
	var starting_room: Room = main_room.duplicate()
	
	var starting_coords: Vector3 = Vector3(MAPSIZE.x / 2 - 1, 0, 0)
	
	starting_room.position = map_to_game_coords(starting_coords, 0)
	
	add_child(starting_room)
	map_malloc(starting_room, starting_coords, 0)
	
	room_queue.append(starting_room)
	
	if time == 0:
		while not room_queue.is_empty():
			expand_map()
	else:
		timer.start(time)
	
	Global.enemies -= 1

func spawn_enemy(pos: Vector3) -> void:
	if randi() % 5 != 6:
		return
	var new_enemy = enemy.instantiate()
	add_child(new_enemy)
	new_enemy.global_position = pos

func connect_room(room_origin: Vector3, room_rotation: float, door: Door, room_candidate: Room, door_origin: Vector3):
	var doors: Array[Door] = room_candidate.get_single_doors() if door.is_single() else room_candidate.get_double_doors()
	
	doors.shuffle()
	for d: Door in doors:
		var new_room_rotation: float = door.get_direction() - d.get_direction() + room_rotation + PI
		new_room_rotation = snap_rotation(new_room_rotation)
		
		var d_origin: Vector3 = rotate_vector(d.get_map_origin(), new_room_rotation)
		var new_room_origin: Vector3 = door_origin - d_origin + room_origin
		if map_malloc(room_candidate, new_room_origin, new_room_rotation):
			
			var new_room: Room = room_candidate.duplicate()
			new_room.position = map_to_game_coords(new_room_origin, new_room_rotation)
			new_room.rotation.y = new_room_rotation
			
			return [new_room, d.get_index()]
	
	return []

func map_malloc(room, origin, rot) -> bool:
	if origin.x < 0 or origin.x >= MAPSIZE.x or origin.y < 0 or origin.y + room.size.y > MAPSIZE.y or origin.z < 0 or origin.z >= MAPSIZE.z:
		return false
	
	var size: Vector3 = rotate_vector(room.size, rot)
	
	if origin.x + size.x < 0 or origin.x + size.x > MAPSIZE.x or origin.z + size.z < 0 or origin.z + size.z > MAPSIZE.z:
		return false
	
	for i: int in range(origin.x, origin.x + size.x, 1 if size.x > 0 else -1):
		for j: int in range(origin.y, origin.y + size.y):
			for k: int in range(origin.z, origin.z + size.z, 1 if size.z > 0 else -1):
				if map_memory[i][j][k]:
					return false
	
	for i: int in range(origin.x, origin.x + size.x, 1 if size.x > 0 else -1):
		for j: int in range(origin.y, origin.y + size.y):
			for k: int in range(origin.z, origin.z + size.z, 1 if size.z > 0 else -1):
				map_memory[i][j][k] = true
	
	return true

func expand_map() -> void:
	var room: Room = room_queue.get(0)
	var origin: Vector3 = game_to_map_coords(room.position, room.rotation.y)
	
	for door: Door in room.get_doors():
		
		if door.is_enabled():
			continue
		
		var connected_door: Door = lookup_door(door)
		if connected_door != null:
			door.set_enabled(true)
			connected_door.set_enabled(true)
			
			spawn_enemy(door.global_position)
			
			register_door(door)
			continue
		
		register_door(door)
		var new_origin: Vector3 = rotate_vector(door.get_map_origin(1, true), room.rotation.y)
		
		room_stash.shuffle()
		
		for r: Room in room_stash:
			var new_room_info: Array = connect_room(origin, room.rotation.y, door, r, new_origin)
			if not new_room_info.is_empty():
				var new_room: Room = new_room_info[0]
				var new_door_index: int = new_room_info[1]
				
				room_queue.append(new_room)
				add_child(new_room)
				
				var new_door: Door = new_room.get_doors()[new_door_index]
				
				door.set_enabled(true)
				new_door.set_enabled(true)
				
				spawn_enemy(door.global_position)
				
				break
	
	room_queue.remove_at(0)

func _on_timer_timeout() -> void:
	if room_queue.is_empty():
		$Timer.set_autostart(false)
		return
	
	expand_map()

func register_door(door: Door, snap: float = 1.0) -> void:
	var key: Vector3 = door.global_position.snapped(Vector3(snap, snap, snap))
	door_dict[key] = door

func lookup_door(door: Door, snap: float = 1.0) -> Door:
	var key: Vector3 = door.global_position.snapped(Vector3(snap, snap, snap))
	return door_dict.get(key, null)


func game_to_map_coords(coords: Vector3, rot: float) -> Vector3:
	var x_offset: int = 0 if is_zero_approx(rot) or is_equal_approx(rot,  PI/2) else 1
	var z_offset: int = 0 if is_zero_approx(rot) or is_equal_approx(rot, -PI/2) else 1
	
	return Vector3(coords.x / 64 + MAPSIZE.x / 2 - x_offset, coords.y / 64, coords.z / 64 - z_offset)

func map_to_game_coords(coords: Vector3, rot: float) -> Vector3:
	var x_offset: int = 0 if is_zero_approx(rot) or is_equal_approx(rot,  PI/2) else 1
	var z_offset: int = 0 if is_zero_approx(rot) or is_equal_approx(rot, -PI/2) else 1
	
	return Vector3((coords.x + x_offset - MAPSIZE.x / 2) * 64, coords.y * 64, (coords.z + z_offset) * 64)


func rotate_vector(vec: Vector3, rot: float) -> Vector3:
	var new_vec: Vector3 = Vector3(vec)
	
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

func snap_rotation(rot: float) -> float:
	rot = fposmod(rot + PI, 2 * PI) - PI
	var cardinals: Array[float] = [0, PI/2, -PI/2, PI, -PI]
	return cardinals.reduce(func(a, b): return a if abs(a - rot) < abs(b - rot) else b)
