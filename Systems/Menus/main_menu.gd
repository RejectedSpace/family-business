extends Control

@onready var main: Control = $Main
@onready var start: Control = $Start
@onready var options: Control = $Options

func _on_start_pressed() -> void:
	main.visible = false
	start.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_solo_pressed() -> void:
	Global.next_scene = "res://Systems/Generation/level.tscn"
	get_tree().change_scene_to_packed(Global.loading_scene)

func _on_coop_pressed() -> void:
	Global.next_scene = "res://Systems/Generation/level_coop.tscn"
	get_tree().change_scene_to_packed(Global.loading_scene)

func _on_back_pressed() -> void:
	main.visible = true
	start.visible = false


func _on_options_pressed() -> void:
	main.visible = false
	options.visible = true


func _on_ms_1_value_changed(value: float) -> void:
	Global.mouse_sens_1 = value


func _on_ms_2_value_changed(value: float) -> void:
	Global.mouse_sens_2 = value


func _on_options_back_pressed() -> void:
	main.visible = true
	options.visible = false
