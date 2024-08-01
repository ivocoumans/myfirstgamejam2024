extends Node


signal light_state_changed()
signal keys_changed()
signal gems_changed()
signal score_changed()
signal switch_changed(id, pressed)
signal player_started()
signal player_finished()


func emit_light_state_changed():
	emit_signal("light_state_changed")


func emit_keys_changed():
	emit_signal("keys_changed")


func emit_gems_changed():
	emit_signal("gems_changed")


func emit_score_changed():
	emit_signal("score_changed")


func emit_switch_changed(id, pressed):
	emit_signal("switch_changed", id, pressed)


func emit_player_started():
	emit_signal("player_started")


func emit_player_finished():
	emit_signal("player_finished")

