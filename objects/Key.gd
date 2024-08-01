extends Area2D


func _on_Key_body_entered(body):
	if !body.is_in_group("player"):
		return
	Globals.add_key()
	queue_free()

