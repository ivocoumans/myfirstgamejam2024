extends KinematicBody2D


var velocity = Vector2.ZERO


func push(push_velocity: Vector2) -> void:
	velocity = move_and_slide(push_velocity, Vector2.ZERO)

