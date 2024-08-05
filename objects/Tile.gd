extends StaticBody2D


const LIGHT_REGION = Rect2(128, 64, 32, 32)
const DARK_REGION = Rect2(192, 64, 32, 32)


var is_pressed = false


func _ready():
	is_pressed = false
	_set_texture()
	var _error = EventBus.connect("light_state_changed", self, "_on_EventBus_light_state_changed")


func _on_Area2D_body_entered(body):
	if is_pressed:
		return
	
	if body.is_in_group("player"):
		is_pressed = true
		
		var state = Globals.get_light_state()
		if state == Globals.LightState.Dark:
			state = Globals.LightState.Light
		else:
			state = Globals.LightState.Dark
		Globals.set_light_state(state)
		
		_set_texture()


func _on_Area2D_body_exited(body):
	if !is_pressed:
		return
	
	if body.is_in_group("player"):
		is_pressed = false


func _on_EventBus_light_state_changed():
	_set_texture()


func _set_texture():
	if Globals.get_light_state() == Globals.LightState.Dark:
		$Sprite.region_rect = DARK_REGION
	else:
		$Sprite.region_rect = LIGHT_REGION

