extends Control

@onready var start: Button = $Start
@onready var quit: Button = $Quit
@onready var solo: Button = $Solo
@onready var coop: Button = $Coop
@onready var back: Button = $Back

func _on_start_pressed() -> void:
	solo.visible = true
	coop.visible = true
	back.visible = true
	start.visible = false
	quit.visible = false


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_solo_pressed() -> void:
	Global.next_scene = "res://Systems/Generation/level.tscn"
	get_tree().change_scene_to_packed(Global.loading_scene)

func _on_coop_pressed() -> void:
	Global.next_scene = "res://Systems/Generation/level_coop.tscn"
	get_tree().change_scene_to_packed(Global.loading_scene)

func _on_back_pressed() -> void:
	solo.visible = false
	coop.visible = false
	back.visible = false
	start.visible = true
	quit.visible = true
