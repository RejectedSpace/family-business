extends Node3D

@onready var reticle: Sprite2D = $Reticle
@onready var animator: AnimationPlayer = $LuparaViewModel/AnimationPlayer
@onready var flash: SpotLight3D = $LuparaViewModel/Arms/SpotLight3D
@onready var flash_timer: Timer = $FlashTimer
@onready var open_timer: Timer = $OpenTimer
@onready var load_timer: Timer = $LoadTimer
@onready var close_timer: Timer = $CloseTimer
@onready var fire_sound: AudioStreamPlayer3D = $FireSound
@onready var open_sound: AudioStreamPlayer3D = $OpenSound
@onready var load_sound: AudioStreamPlayer3D = $LoadSound
@onready var close_sound: AudioStreamPlayer3D = $CloseSound

func _ready() -> void:
	var view_model = get_parent().get_parent()
	reload_finished.connect(view_model._on_model_reload_finished)
	holstered.connect(view_model._on_model_holstered)
	
	reticle.position = DisplayServer.window_get_size() / 2.0
	reticle.scale.x = DisplayServer.window_get_size().x / 1920.0 * .3
	reticle.scale.y = DisplayServer.window_get_size().y / 1200.0 * .3
	play("Deploy")

func play(anim_name: StringName) -> void:
	if anim_name == "Reload":
		if animator.is_playing():
			return
		open_timer.start()
	else:
		open_timer.stop()
		load_timer.stop()
		close_timer.stop()
	if anim_name == "Fire":
		flash_timer.start()
		fire_sound.play()
		flash.visible = true
	
	animator.play(anim_name)

func is_busy() -> bool:
	return animator.get_current_animation() != "Reload" and animator.is_playing()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Holster":
		visible = false
		holstered.emit()
	if anim_name == "Reload":
		reload_finished.emit()

func _on_flash_timer_timeout() -> void:
	flash.visible = false

func _on_open_timer_timeout() -> void:
	open_sound.play()
	load_timer.start()

func _on_load_timer_timeout() -> void:
	load_sound.play()
	close_timer.start()

func _on_close_timer_timeout() -> void:
	close_sound.play()

signal holstered
signal reload_finished
