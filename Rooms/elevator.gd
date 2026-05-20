extends Node3D

@onready var animator: AnimationPlayer = $ElevatorDoors/AnimationPlayer
@onready var button: StaticBody3D = $Button

var open = false

func _on_button_pressed() -> void:
	open = not open
	if open:
		animator.play("Open")
	else:
		animator.play("Close")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Close":
		closed.emit()
	#if anim_name == "Open":
		#button.activate()

func activate() -> void:
	button.activate()

signal closed
