extends KinematicBody2D


export (float) var speed: float = 200
export (float) var push_speed: float = 100


var is_paused = false
var inertia = 200
var direction = Vector2.ZERO
var velocity = Vector2.ZERO


func reset(reset_position = null):
	is_paused = false
	if reset_position != null:
		position = reset_position


func pause(paused):
	is_paused = paused


func get_rect():
	var size = $Sprite.get_rect().size
	return Rect2(position - (size / 2), size)


func _ready():
	reset()


func _physics_process(_delta):
	if is_paused:
		return
	
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	velocity = move_and_slide(direction.normalized() * speed, Vector2.ZERO)
	if get_slide_count() > 0:
		check_box_collision(direction)


func check_box_collision(motion: Vector2) -> void:
	if abs(motion.x) + abs(motion.y) > 1:
		return
	
	var box = get_slide_collision(0).collider
	if box and box.is_in_group("block"):
		box.push(direction * push_speed)
	
#	move_and_slide(direction.normalized() * speed, Vector2.ZERO, false, 4, PI/4, false)
#
#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		if collision.collider.is_in_group("block"):
#			collision.collider.apply_central_impulse(-collision.normal * inertia)

