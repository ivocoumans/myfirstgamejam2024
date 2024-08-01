extends Control


func _ready():
	_update_text()
	var _error = EventBus.connect("keys_changed", self, "_on_EventBus_keys_changed")


func _update_text():
	$HBoxContainer/Value.text = str(Globals.get_keys())


func _on_EventBus_keys_changed():
	_update_text()

