extends Node

var loading_scene: PackedScene = preload("res://Systems/Loading/loading_scene.tscn")
var player: Entity
var next_scene: String = "res://Systems/Menus/main.tscn"

var enemies: int = 1

func _process(delta: float) -> void:
	if enemies == 0:
		pass #get_tree().quit()
