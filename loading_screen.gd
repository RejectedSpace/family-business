extends Node2D

@onready var loading_bar = $LoadingBar

func _ready() -> void:
	ResourceLoader.load_threaded_request(Global.next_scene)
	loading_bar.scale.x = DisplayServer.window_get_size().x / 825
	loading_bar.scale.y = DisplayServer.window_get_size().y / 250
	loading_bar.position = DisplayServer.window_get_size() / 2

func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(Global.next_scene, progress)
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(Global.next_scene)
		get_tree().change_scene_to_packed(packed_scene)
