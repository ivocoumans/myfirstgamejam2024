extends StaticBody2D


export (bool) var is_open = false
export (bool) var is_key_required = false
export (int) var switch_id = -1


func _set_texture():
	if !is_open:
		$Sprite.modulate.a8 = 255
	else:
		$Sprite.modulate.a8 = 0


func _set_collision():
	$CollisionShape2D.disabled = is_open


func _ready():
	_set_texture()
	_set_collision()
	
	var	_error = EventBus.connect("switch_changed", self, "_on_EventBus_switch_changed")


func _on_Area2D_body_entered(body):
	if !body.is_in_group("player") or is_open or (is_key_required and !Globals.has_key()) or switch_id >= 0:
		return
	
	if is_key_required:
		Globals.remove_key()
	_toggle_door(!is_open)


func _on_EventBus_switch_changed(id, pressed):
	if switch_id < 0 or switch_id != id:
		return
	_toggle_door(pressed)


func _toggle_door(open = false):
	is_open = open
	_set_texture()
	call_deferred("_set_collision")

