extends Area2D


func _on_Start_body_exited(body):
	if !body.is_in_group("player"):
		return
	EventBus.emit_player_started()

