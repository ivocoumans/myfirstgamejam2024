extends Area2D


func _on_Finish_body_entered(body):
	if !body.is_in_group("player"):
		return
	EventBus.emit_player_finished()

