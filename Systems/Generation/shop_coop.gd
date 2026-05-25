extends Node3D

@onready var player_1: Entity = $GridContainer/SubViewportContainer/SubViewport/Player
@onready var player_2: Entity = $GridContainer/SubViewportContainer2/SubViewport/Player2
@onready var elevator: Node3D = $Elevator

func _on_elevator_closed() -> void:
	Global.next_scene = "res://Systems/Generation/level.tscn"
	Global.player_1_data = player_1.get_data() if player_1.global_position.z < 0 else []
	Global.player_2_data = player_2.get_data() if player_2.global_position.z < 0 else []
	get_tree().change_scene_to_packed(Global.loading_scene)
