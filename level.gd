extends Node3D

@onready var map = $Map
@onready var player = $Player

func _ready() -> void:
	map.generate()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("9"):
		$Camera3D.current = !$Camera3D.current
	get_tree().call_group("enemies", "update_target", player)
