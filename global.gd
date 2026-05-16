extends Node

var loading_screen: PackedScene = preload("res://loading_screen.tscn")

var next_scene: String = "res://main.tscn"

var enemies: int = 1

func _process(delta: float) -> void:
	if enemies == 0:
		pass #get_tree().quit()
