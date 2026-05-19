extends StaticBody3D

@onready var animator = $AnimationPlayer
@onready var interactable = $Interactable

var active = false

func _ready() -> void:
	if not active:
		animator.play("Inactive")
		set_active(false)

func activate() -> void:
	set_active(true)
	animator.play("Activate")

func press() -> void:
	pressed.emit()
	animator.play("Press")
	set_active(false)
	interactable.set_collision_layer_value(9, false)

func set_active(value: bool) -> void:
	active = value
	interactable.set_collision_layer_value(9, value)

func _on_interactable_interacted(interactor: Interactor) -> void:
	press()

signal pressed
