extends Node

var loading_scene: PackedScene = preload("res://Systems/Loading/loading_scene.tscn")
var player_data: Array
var next_scene: String = "res://Systems/Menus/main.tscn"
var button

var old_count: int = 0
var enemies: int = 0

func _process(delta: float) -> void:
	if old_count != enemies and enemies == 0 and button:
		button.activate()
	old_count = enemies
