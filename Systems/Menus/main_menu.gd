extends Control

func _on_start_pressed() -> void:
	Global.next_scene = "res://Systems/Generation/level.tscn"
	Global.enemies -= 1
	get_tree().change_scene_to_packed(Global.loading_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
