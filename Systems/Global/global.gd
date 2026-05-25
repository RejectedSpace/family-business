extends Node

var loading_scene: PackedScene = preload("res://Systems/Loading/loading_scene.tscn")
var player_1_data: Array
var player_2_data: Array
var next_scene: String = "res://Systems/Menus/main.tscn"
var button

var level_count: int = 0
var cash: int = 0

func reset() -> void:
	cash = 0
	level_count = 0
