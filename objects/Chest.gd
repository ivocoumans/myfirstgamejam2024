extends StaticBody2D


const CLOSED_REGION = Rect2(96, 160, 32, 32)
const OPEN_REGION = Rect2(128, 160, 32, 32)


export (bool) var is_open = false
export (bool) var is_key_required = false
export (int) var switch_id = -1


func _set_texture():
	if !is_open:
		$Sprite.region_rect = CLOSED_REGION
	else:
		$Sprite.region_rect = OPEN_REGION


func _ready():
	_set_texture()
	var	_error = EventBus.connect("switch_changed", self, "_on_EventBus_switch_changed")


func _on_Area2D_body_entered(body):
	if !body.is_in_group("player") or is_open or (is_key_required and !Globals.has_key()) or switch_id >= 0:
		return
	
	if is_key_required:
		Globals.remove_key()
	_toggle_open(!is_open)


func _on_EventBus_switch_changed(id, pressed):
	if switch_id < 0 or switch_id != id:
		return
	_toggle_open(pressed)


func _toggle_open(open = false):
	is_open = open
	_set_texture()
	Globals.add_gem()

