extends Node3D

class_name Gun

@onready var hitscan = $Hitscan

@export var damage: float = 20.0

@export var ammo_cappacity: int = 16
@export var clip_size: int = 2
@export var full_clip_replace: bool = true

var clip: int
var ammo: int

func _ready() -> void:
	clip = clip_size
	ammo = ammo_cappacity

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

func reload() -> void:
	var amount = clip_size if full_clip_replace else clip_size - clip
	clip = min(amount, ammo)
	ammo -= min(amount, ammo)
