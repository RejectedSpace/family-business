extends Node3D

@onready var map: Node3D = $Map
@onready var player: Entity = $Player
@onready var elevator: Node3D = $Elevator

func _ready() -> void:
	map.MAPSIZE += Vector3(Global.map_size, Global.map_size / 2, Global.map_size)
	map.generate()
	get_tree().call_group("enemies", "set_target", [player])

func _process(delta) -> void:
	elevator.set_label("Quota:\n$" + str(Global.cash) + " / $" + str(Global.get_quota()) + "\n" + str(3 - Global.level_count % 3) + " floors left")

func _on_elevator_closed() -> void:
	var scene = "Systems/Generation/level" if Global.level_count % 3 < 2 else "shop"
	
	Global.next_scene = "res://" + scene + ".tscn"
	Global.player_1_data = player.get_data() if player.global_position.z < 0 else []
	Global.level_count += 1
	get_tree().change_scene_to_packed(Global.loading_scene)
