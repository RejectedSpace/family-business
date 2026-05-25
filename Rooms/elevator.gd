extends Node3D

@onready var door_animator: AnimationPlayer = $ElevatorDoors/AnimationPlayer
@onready var elevator_animator: AnimationPlayer = $AnimationPlayer
@onready var button: StaticBody3D = $Button
@onready var label: Label = $SubViewport/Label

var open = false

func _ready() -> void:
	if Global.level_count > 0:
		elevator_animator.play("Rise")
	else:
		activate()

func set_label(text) -> void:
	label.text = text

func _on_button_pressed() -> void:
	open = not open
	if open:
		door_animator.play("Open")
	else:
		door_animator.play("Close")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Close":
		closed.emit()
	if anim_name == "Open" or anim_name == "Rise":
		activate()

func activate() -> void:
	button.activate()

signal closed
