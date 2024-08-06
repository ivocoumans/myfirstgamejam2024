extends StaticBody2D


const TRAP_CLOSED_REGION = Rect2(128, 32, 32, 32)
const TRAP_OPEN_REGION = Rect2(160, 32, 32, 32)
const DOOR_CLOSED_REGION = Rect2(0, 0, 32, 32)
const SFX_SWITCH_DOOR = preload("res://assets/audio/sfx/switch_door.wav")


export (bool) var is_open = false
export (bool) var is_key_required = false
export (int) var switch_id = -1


func _set_texture():
	var open_region = TRAP_OPEN_REGION
	var closed_region = TRAP_CLOSED_REGION
	var open_alpha = 255
	var closed_alpha = 255
	
	if is_key_required:
		closed_region = DOOR_CLOSED_REGION
		open_alpha = 0
	
	if is_open:
		$Sprite.region_rect = open_region
		$Sprite2.region_rect = open_region
		$Sprite.modulate.a8 = open_alpha
		$Sprite2.modulate.a8 = open_alpha
	else:
		$Sprite.region_rect = closed_region
		$Sprite2.region_rect = closed_region
		$Sprite.modulate.a8 = closed_alpha
		$Sprite2.modulate.a8 = closed_alpha


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
	SFX.play(SFX_SWITCH_DOOR)

