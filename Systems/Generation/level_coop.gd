extends Node3D

@onready var map: Node3D = $Map
@onready var player_1: Entity = $GridContainer/SubViewportContainer/SubViewport/Player
@onready var player_2: Entity = $GridContainer/SubViewportContainer2/SubViewport/Player2
@onready var elevator: Node3D = $Elevator

func _ready() -> void:
	map.generate()
	get_tree().call_group("enemies", "set_target", player_1)

	
func _on_elevator_closed() -> void:
	var scene = "Systems/Generation/level_coop" if Global.level_count % 3 < 2 else "shop_coop"
	
	Global.next_scene = "res://" + scene + ".tscn"
	Global.player_1_data = player_1.get_data() if player_1.global_position.z < 0 else []
	Global.player_2_data = player_2.get_data() if player_2.global_position.z < 0 else []
	Global.level_count += 1
	get_tree().change_scene_to_packed(Global.loading_scene)
