extends Control


func _ready():
	_update_text()
	var _error = EventBus.connect("score_changed", self, "_on_EventBus_score_changed")


func _update_text():
	$Value.text = str(Globals.get_score())


func _on_EventBus_score_changed():
	_update_text()

