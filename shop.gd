extends Node3D

@onready var player: Entity = $Player
@onready var elevator: Node3D = $Elevator

func _on_elevator_closed() -> void:
	Global.next_scene = "res://Systems/Generation/level.tscn"
	Global.player_1_data = player.get_data() if player.global_position.z < 0 else []
	get_tree().change_scene_to_packed(Global.loading_scene)
