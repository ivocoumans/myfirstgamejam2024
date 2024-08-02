extends Control


func _ready():
	_update_text()
	var _error = EventBus.connect("time_changed", self, "_on_EventBus_time_changed")


func _update_text():
	$Value.text = str(Globals.get_time())


func _on_EventBus_time_changed():
	_update_text()

