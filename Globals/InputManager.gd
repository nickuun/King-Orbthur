# InputManager.gd
extends Node

func get_movement_vector() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

func is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("dash")
