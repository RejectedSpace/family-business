extends Node2D

@onready var progress_label = $Control/Progress

const ASPECT_WIDTH: float = 320.0
const ASPECT_HEIGHT: float = 200.0

func _ready() -> void:
	ResourceLoader.load_threaded_request(Global.next_scene)

func set_progress(progress: float) -> void:
	progress_label.set_text(str(progress).pad_decimals(0) + "%")
