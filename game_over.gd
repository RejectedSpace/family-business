extends Node2D

@onready var stats: Label = $Stats

var packed_scene = preload("res://Systems/Menus/main.tscn")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	stats.text = str(Global.quota_count, "\n$", Global.cash)

func _on_button_pressed() -> void:
	Global.reset()
	get_tree().change_scene_to_packed(packed_scene)
