extends Node

var loading_scene: PackedScene = preload("res://Systems/Loading/loading_scene.tscn")
var player_1_data: Array
var player_2_data: Array
var next_scene: String = "res://Systems/Menus/main.tscn"
var button

var mouse_sens_1 = 0.05
var mouse_sens_2 = 0.05

var level_count: int = 0
var quota_count: int = 0
var cash: int = 100
var map_size: int = 0

func reset() -> void:
	cash = 0
	level_count = 0
	quota_count = 0
	player_1_data = []
	player_2_data = []

func get_sensitivity(player_id: int) -> float:
	assert(player_id == 1 or player_id == 2, "Can't get mouse sensitivity (Invalid Player ID: " + str(player_id) + ")")
	return mouse_sens_1 if player_id == 1 else mouse_sens_2

func get_quota() -> int:
	return (1 + quota_count * (quota_count + 1)) * 100

func get_player_data(player_id: int) -> Array:
	assert(player_id == 1 or player_id == 2, "Can't get player data (Invalid Player ID: " + str(player_id) + ")")
	return player_1_data if player_id == 1 else player_2_data
