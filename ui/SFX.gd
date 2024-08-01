extends AudioStreamPlayer


#var JumpSound = preload("res://assets/jump.wav")


func mute(mute: bool) -> void:
	var volume_db = -12
	if mute:
		volume_db = -80
	SFX.volume_db = volume_db


#func play_jump():
#	_play_sound(JumpSound)


func _play_sound(stream):
	SFX.stop()
	SFX.stream = stream
	SFX.play()

