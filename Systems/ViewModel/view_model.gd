extends Camera3D

@onready var rig: Node3D = $Rig
@onready var reticle: Sprite2D = $Reticle
@onready var animator: AnimationPlayer = $Rig/LuparaViewModel/AnimationPlayer
@onready var flash: SpotLight3D = $Rig/LuparaViewModel/Arms/SpotLight3D
@onready var flash_timer: Timer = $FlashTimer
@onready var open_timer: Timer = $OpenTimer
@onready var load_timer: Timer = $LoadTimer
@onready var close_timer: Timer = $CloseTimer
@onready var fire_sound: AudioStreamPlayer3D = $FireSound
@onready var open_sound: AudioStreamPlayer3D = $OpenSound
@onready var load_sound: AudioStreamPlayer3D = $LoadSound
@onready var close_sound: AudioStreamPlayer3D = $CloseSound

const SMOOTHING_FACTOR = 5
const SWAY_FACTOR = 5e-3

func _ready() -> void:
	reticle.position = DisplayServer.window_get_size() / 2.0
	reticle.scale.x = DisplayServer.window_get_size().x / 1920.0 * .3
	reticle.scale.y = DisplayServer.window_get_size().y / 1200.0 * .3
	play("Deploy")

func play(anim_name: StringName) -> void:
	if anim_name == "Fire":
		flash_timer.start()
		fire_sound.play()
		flash.visible = true
	if anim_name == "Reload":
		open_timer.start()
	
	animator.play(anim_name)

func is_busy() -> bool:
	return animator.is_playing()

func _process(delta: float) -> void:
	rig.position.x = lerp(rig.position.x, 0.0, delta * SMOOTHING_FACTOR)
	rig.position.y = lerp(rig.position.y, 0.0, delta * SMOOTHING_FACTOR)

func sway(amount: Vector2) -> void:
	rig.position.x += amount.x * SWAY_FACTOR
	rig.position.y += amount.y * SWAY_FACTOR

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Holster":
		play("Deploy")
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

signal reload_finished
