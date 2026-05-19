extends Node3D

@onready var map = $Map
@onready var player = $Player
@onready var elevator = $Elevator

func _ready() -> void:
	if Global.player:
		player = Global.player
	map.generate()
	elevator.activate()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("9"):
		$Camera3D.current = !$Camera3D.current
	get_tree().call_group("enemies", "update_target", player)

func _on_elevator_change_scene() -> void:
	Global.next_scene = "res://Systems/Generation/level.tscn"
	Global.player = player
	get_tree().change_scene_to_packed(Global.loading_scene)
