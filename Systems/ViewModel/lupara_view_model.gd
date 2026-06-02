extends ViewModel

@onready var open_timer: Timer = $SoundTimers/OpenTimer
@onready var load_timer: Timer = $SoundTimers/LoadTimer
@onready var load_sound: AudioStreamPlayer3D = $LoadSound

func play(anim_name: StringName) -> void:
	if anim_name == "Reload" and not animator.is_playing():
		open_timer.start()
	
	super.play(anim_name)

func _on_open_timer_timeout() -> void:
	open_sound.play()
	load_timer.start()

func _on_load_timer_timeout() -> void:
	load_sound.play()
	close_timer.start()
