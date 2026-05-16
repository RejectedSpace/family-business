extends Camera3D

@onready var rig: Node3D = $Rig

const SMOOTHING_FACTOR = 5
const SWAY_FACTOR = 5e-3

func _process(delta: float) -> void:
	rig.position.x = lerp(rig.position.x, 0.0, delta * SMOOTHING_FACTOR)
	rig.position.y = lerp(rig.position.y, 0.0, delta * SMOOTHING_FACTOR)

func sway(amount: Vector2) -> void:
	rig.position.x += amount.x * SWAY_FACTOR
	rig.position.y += amount.y * SWAY_FACTOR
