extends Camera3D

@onready var rig: Node3D = $Rig

var model: Node3D

const SMOOTHING_FACTOR = 5
const SWAY_FACTOR = 5e-3

func play(anim_name: StringName) -> void:
	model.play(anim_name)

func set_model(view_model: PackedScene):
	if model:
		rig.remove_child(model)
	
	model = view_model.instantiate()
	rig.add_child(model)

func is_busy() -> bool:
	return model.is_busy()

func _process(delta: float) -> void:
	rig.position.x = lerp(rig.position.x, 0.0, delta * SMOOTHING_FACTOR)
	rig.position.y = lerp(rig.position.y, 0.0, delta * SMOOTHING_FACTOR)

func sway(amount: Vector2) -> void:
	rig.position.x += amount.x * SWAY_FACTOR
	rig.position.y += amount.y * SWAY_FACTOR

func _on_model_reload_finished() -> void:
	reload_finished.emit()

func _on_model_holstered() -> void:
	holstered.emit()

signal holstered
signal reload_finished
