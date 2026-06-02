extends Item

class_name Gun

@onready var hitscan = $Hitscan

@export var base_damage: float = 0.0
@export var base_mag_size: int = 0
@export var base_reserve_size: int = 0
@export var full_mag_replace: bool = false
@export var view_model: PackedScene

var mag: int
var reserve: int
var damage: float
var reserve_size: int
var mag_size: int

func _ready() -> void:
	assert(function_name == &"equip_gun")
	
	damage = base_damage
	reserve_size = base_reserve_size
	mag_size = base_mag_size
	
	mag = mag_size
	reserve = reserve_size

func for_player(player_id: int):
	for child in get_children():
		if child.name != "Hitscan" and child.name != "AnimationPlayer":
			for mesh: MeshInstance3D in child.get_children():
				mesh.set_layer_mask_value(1, false)
				mesh.set_layer_mask_value(player_id * 2 + 4, true)

func get_view_model() -> PackedScene:
	return view_model

func get_hitscan() -> Node3D:
	return hitscan

func get_damage() -> float:
	return damage

func get_mag() -> int:
	return mag

func mag_full() -> bool:
	return mag >= mag_size

func mag_empty() -> bool:
	return mag <= 0

func reserve_empty() -> bool:
	return reserve <= 0

func get_reserve() -> int:
	return reserve

func shoot() -> void:
	mag -= 1

func load_data(data: Array) -> void:
	mag = data[1]
	reserve = data[2]

func get_data() -> Array:
	return [duplicate(), mag, reserve]

func reload() -> void:
	if full_mag_replace:
		mag = 0
	var amount = min(mag_size - mag, reserve)
	mag += amount
	reserve -= amount
