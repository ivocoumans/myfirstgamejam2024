extends Area2D


const SFX_ITEM = preload("res://assets/audio/sfx/item.wav")


func _on_Key_body_entered(body):
	if !body.is_in_group("player"):
		return
	Globals.add_key()
	SFX.play(SFX_ITEM)
	queue_free()

