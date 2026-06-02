extends Node3D

@onready var player_1: Entity = $GridContainer/SubViewportContainer/SubViewport/Player
@onready var player_2: Entity = $GridContainer/SubViewportContainer2/SubViewport/Player2
@onready var elevator: Node3D = $Elevator
var infected = preload("res://Entities/enemy.tscn")
var kill = false

func _ready() -> void:
	if Global.cash < Global.get_quota():
		kill = true

func _process(delta: float) -> void:
	elevator.set_label(str("Quota:\n$", Global.cash, " / $", Global.get_quota(), "\n", "Quota Passed!" if not kill else "Quota Failed!"))
	if kill and elevator.open:
		get_tree().quit()
	
func _on_elevator_closed() -> void:
	Global.next_scene = "res://Systems/Generation/level_coop.tscn"
	Global.quota_count += 1
	Global.map_size += 2
	Global.player_1_data = player_1.get_data() if player_1.global_position.z < 0 else []
	Global.player_2_data = player_2.get_data() if player_2.global_position.z < 0 else []
	get_tree().change_scene_to_packed(Global.loading_scene)
