extends Node3D

@onready var map = $Map

func _ready() -> void:
	map.generate()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("9"):
		$Camera3D.current = !$Camera3D.current

func _physics_process(delta: float) -> void:
	get_tree().call_group("enemies", "update_target_location", $Player.global_transform.origin)
