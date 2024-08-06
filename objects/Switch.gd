extends Area2D


const DEPRESSED_REGION = Rect2(0, 32, 32, 32)
const PRESSED_REGION = Rect2(32, 32, 32, 32)
const SFX_SWITCH_DOOR = preload("res://assets/audio/sfx/switch_door.wav")


export (bool) var is_toggled = false
export (int) var switch_id = -1


var is_pressed = false


func _ready():
	is_pressed = false
	_set_texture()


func _set_texture():
	if is_pressed:
		$Sprite.region_rect = PRESSED_REGION
	else:
		$Sprite.region_rect = DEPRESSED_REGION


func _on_Switch_body_entered(body):
	if is_pressed:
		return
	
	if body.is_in_group("player") or body.is_in_group("block"):
		_toggle_switch(true)


func _on_Switch_body_exited(body):
	if !is_pressed or is_toggled:
		return
	
	var parent_name = get_parent().name
	var light_state = Globals.get_light_state()
	if body.is_in_group("block") and (parent_name == "Light" and light_state != 0 or parent_name == "Dark" and light_state != 1):
		return
	
	if body.is_in_group("player") or body.is_in_group("block"):
		_toggle_switch(false)


func _toggle_switch(pressed = false):
	is_pressed = pressed
	_set_texture()
	EventBus.emit_switch_changed(switch_id, is_pressed)
	SFX.play(SFX_SWITCH_DOOR)


