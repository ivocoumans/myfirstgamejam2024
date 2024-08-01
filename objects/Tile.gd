extends Area2D


const LIGHT_REGION = Rect2(96, 96, 32, 32)
const DARK_REGION = Rect2(64, 64, 32, 32)


var is_pressed = false
var state = null


func _ready():
	is_pressed = false
	state = Globals.LightState.Light
	_set_texture()


func _on_Tile_body_entered(body):
	if is_pressed:
		return
	
	if body.is_in_group("player"):
		is_pressed = true
		
		state = Globals.get_light_state()
		if state == Globals.LightState.Dark:
			state = Globals.LightState.Light
		else:
			state = Globals.LightState.Dark
		Globals.set_light_state(state)
		
		_set_texture()


func _on_Tile_body_exited(body):
	if !is_pressed:
		return
	
	if body.is_in_group("player"):
		is_pressed = false


func _set_texture():
	if state == Globals.LightState.Dark:
		$Sprite.region_rect = DARK_REGION
	else:
		$Sprite.region_rect = LIGHT_REGION

