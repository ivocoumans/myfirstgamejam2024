extends KinematicBody2D


const ITEM_KEY_TEXTURE = preload("res://assets/key.png")
const ITEM_GEM_TEXTURE= preload("res://assets/gem.png")


export (float) var speed: float = 200
export (float) var push_speed: float = 100


var is_paused = true
var is_frozen = false
var inertia = 200
var direction = Vector2.ZERO
var velocity = Vector2.ZERO


func reset(reset_position = null):
	is_paused = true
	if reset_position != null:
		position = reset_position


func pause(paused):
	is_paused = paused
	if paused:
		$AnimationPlayer.stop()


func get_rect():
	var size = $Sprite.get_rect().size
	return Rect2(position - (size / 2), size)


func set_collision(enabled):
	call_deferred("_set_collision", enabled)


func _set_collision(enabled):
	$CollisionShape2D.disabled = !enabled


func _check_box_collision(motion: Vector2) -> void:
	if abs(motion.x) + abs(motion.y) > 1:
		return
	
	var box = get_slide_collision(0).collider
	if box and box.is_in_group("block"):
		box.push(direction * push_speed)


func _on_EventBus_gems_changed():
	_play_item_animation(ITEM_GEM_TEXTURE)


func _on_EventBus_keys_changed():
	_play_item_animation(ITEM_KEY_TEXTURE)


func _play_item_animation(texture):
	if is_paused:
		return
	is_frozen = true
	$SpriteItem.texture = texture
	$SpriteItem.visible = true
	$AnimationPlayer.play("item")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "item":
		$SpriteItem.visible = false
		$SpriteItem.texture = null
		is_frozen = false


func _ready():
	reset()
	var _error = EventBus.connect("gems_changed", self, "_on_EventBus_gems_changed")
	_error = EventBus.connect("keys_changed", self, "_on_EventBus_keys_changed")


func _physics_process(_delta):
	if is_paused or is_frozen:
		return
	
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if direction.x < 0:
		$AnimationPlayer.play("walk_left")
	elif direction.x > 0:
		$AnimationPlayer.play("walk_right")
	elif direction.y < 0:
		$AnimationPlayer.play("walk_up")
	elif direction.y > 0:
		$AnimationPlayer.play("walk_down")
	else:
		$AnimationPlayer.stop(true)
	
	velocity = move_and_slide(direction.normalized() * speed, Vector2.ZERO)
	if get_slide_count() > 0:
		_check_box_collision(direction)

