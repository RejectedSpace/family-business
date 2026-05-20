extends Node3D

@onready var map: Node3D = $Map
@onready var player: Entity = $Player
@onready var elevator: Node3D = $Elevator

func _ready() -> void:
	map.generate()
	elevator.activate()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("9"):
		$Camera3D.current = !$Camera3D.current
	get_tree().call_group("enemies", "update_target", player)

func _on_elevator_closed() -> void:
	Global.next_scene = "res://Systems/Generation/level.tscn"
	Global.player_data = player.get_data()
	get_tree().change_scene_to_packed(Global.loading_scene)
