extends Node2D

func _ready() -> void:
	ResourceLoader.load_threaded_request(Global.next_scene)

func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(Global.next_scene, progress)
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(Global.next_scene)
		get_tree().change_scene_to_packed(packed_scene)
