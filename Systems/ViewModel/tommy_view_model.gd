extends ViewModel

func play(anim_name: StringName) -> void:
	if anim_name == "Reload" and not animator.is_playing():
		open_sound.play()
		close_timer.start()
	
	super.play(anim_name)
