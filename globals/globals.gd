extends Node


enum LightState {
	Light,
	Dark
}


var _light_state = LightState.Light
var _keys = 0
var _gems_in_level = 0
var _gems = 0
var _score = 0

func get_light_state():
	return _light_state


func set_light_state(state):
	_light_state = state
	EventBus.emit_light_state_changed()


func get_keys():
	return _keys


func has_key():
	return _keys > 0


func add_key():
	_keys += 1
	EventBus.emit_keys_changed()


func remove_key():
	if _keys <= 0:
		return
	_keys -= 1
	EventBus.emit_keys_changed()


func get_gems_in_level():
	return _gems_in_level


func set_gems_in_level(gems):
	_gems_in_level = gems
	EventBus.emit_gems_changed()


func get_gems():
	return _gems


func add_gem():
	_gems += 1
	EventBus.emit_gems_changed()


func get_score():
	return _score


func increase_score():
	_score += 1
	EventBus.emit_score_changed()


func reset():
	_light_state = LightState.Light
	_keys = 0
	_score = 0
	
	EventBus.emit_light_state_changed()
	EventBus.emit_keys_changed()
	EventBus.emit_score_changed()

