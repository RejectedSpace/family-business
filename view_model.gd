extends Camera3D

@onready var rig: Node3D = $Rig
@onready var reticle: Sprite2D = $Reticle
@onready var animator: AnimationPlayer = $Rig/LuparaViewModel/AnimationPlayer
@onready var timer: Timer = $FlashTimer
@onready var flash: SpotLight3D = $Rig/LuparaViewModel/Arms/SpotLight3D

const SMOOTHING_FACTOR = 5
const SWAY_FACTOR = 5e-3

func _ready() -> void:
	reticle.position = DisplayServer.window_get_size() / 2.0
	reticle.scale.x = DisplayServer.window_get_size().x / 1920.0 * .3
	reticle.scale.y = DisplayServer.window_get_size().y / 1200.0 * .3
	play("Deploy")

func play(anim_name: StringName) -> void:
	if anim_name == "Fire":
		timer.start()
		flash.visible = true
	
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

func _on_flash_timer_timeout() -> void:
	flash.visible = false
