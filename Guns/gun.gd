extends Node3D

class_name Gun

@onready var hitscan = $Hitscan

@export var base_damage: float = 20.0

@export var base_ammo_cappacity: int = 16
@export var base_clip_size: int = 2
@export var full_clip_replace: bool = false
@export var price: int = 10
@export var view_model: PackedScene
@export var rarity: int = 0

var clip: int
var ammo: int
var damage: float
var ammo_cappacity: int
var clip_size: int

func _ready() -> void:
	damage = base_damage
	ammo_cappacity = base_ammo_cappacity
	clip_size = base_clip_size
	
	clip = clip_size
	ammo = ammo_cappacity

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

func get_clip() -> int:
	return clip

func clip_full() -> bool:
	return clip >= clip_size

func clip_empty() -> bool:
	return clip <= 0

func no_ammo() -> bool:
	return ammo <= 0

func get_ammo() -> int:
	return ammo

func shoot() -> void:
	clip -= 1

func load_data(data: Array) -> void:
	clip = data[1]
	ammo = data[2]

func get_data() -> Array:
	return [duplicate(), clip, ammo]

func reload() -> void:
	if full_clip_replace:
		clip = 0
	var amount = clip_size - clip
	clip += min(amount, ammo)
	ammo -= min(amount, ammo)
