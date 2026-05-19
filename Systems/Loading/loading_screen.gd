extends Node2D

@onready var loading_text = $LoadingText
@onready var progress_label = $LoadingText/Panel/ProgressLabel

const ASPECT_WIDTH: float = 320.0
const ASPECT_HEIGHT: float = 200.0

func _ready() -> void:
	ResourceLoader.load_threaded_request(Global.next_scene)
	loading_text.scale.x = DisplayServer.window_get_size().y / ASPECT_HEIGHT
	loading_text.scale.y = DisplayServer.window_get_size().x / ASPECT_WIDTH
	loading_text.position = Vector2(DisplayServer.window_get_size()) - loading_text.scale * loading_text.size

func set_progress(progress: float) -> void:
	progress_label.set_text(str(progress).pad_decimals(0) + "%")
