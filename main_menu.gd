extends Control



func _on_start_pressed() -> void:
	Global.next_scene = "res://level.tscn"
	get_tree().change_scene_to_packed(Global.loading_screen)


func _on_quit_pressed() -> void:
	get_tree().quit()
