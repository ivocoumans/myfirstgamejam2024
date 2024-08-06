extends KinematicBody2D


const SFX_BLOCK = preload("res://assets/audio/sfx/block.wav")
const SFX_DURATION = 0.3


var velocity = Vector2.ZERO
var is_playing_sfx = false
var sfx_timer = 0
var _initial_position = Vector2.ZERO


func _ready():
	_initial_position = position


func _process(delta):
	sfx_timer += delta
	if sfx_timer > SFX_DURATION:
		sfx_timer = 0
		is_playing_sfx = false


func push(push_velocity: Vector2) -> void:
	velocity = move_and_slide(push_velocity, Vector2.ZERO)
	if !is_playing_sfx:
		is_playing_sfx = true
		SFX.play(SFX_BLOCK)

