extends Node3D

@onready var player: Entity = $Player
@onready var elevator: Node3D = $Elevator
var infected = preload("res://Entities/enemy.tscn")
var kill = false

func _ready() -> void:
	if Global.cash < Global.get_quota():
		kill = true

func _process(delta) -> void:
	elevator.set_label("Quota:\n$" + str(Global.cash) + " / $" + str(Global.get_quota()) + "\n" + ("Quota Passed!" if not kill else "Quota Failed!"))
	if kill and elevator.open:
		player.die()

func _on_elevator_closed() -> void:
	Global.next_scene = "res://Systems/Generation/level.tscn"
	Global.quota_count += 1
	Global.map_size += 2
	Global.player_1_data = player.get_data() if player.global_position.z < 0 else []
	get_tree().change_scene_to_packed(Global.loading_scene)
