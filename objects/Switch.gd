extends Area2D


const DEPRESSED_REGION = Rect2(128, 64, 32, 32)
const PRESSED_REGION = Rect2(128, 96, 32, 32)


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
		is_pressed = true
		_set_texture()
		EventBus.emit_switch_changed(switch_id, is_pressed)


func _on_Switch_body_exited(body):
	if !is_pressed or is_toggled:
		return
	
	if body.is_in_group("player") or body.is_in_group("block"):
		is_pressed = false
		_set_texture()
		EventBus.emit_switch_changed(switch_id, is_pressed)

