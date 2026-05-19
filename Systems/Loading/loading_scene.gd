extends Node3D

@onready var loading_screen = $LoadingScreen

func _ready() -> void:
	ResourceLoader.load_threaded_request(Global.next_scene)

func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(Global.next_scene, progress)
	
	loading_screen.set_progress(progress[0])
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(Global.next_scene)
		get_tree().change_scene_to_packed(packed_scene)
