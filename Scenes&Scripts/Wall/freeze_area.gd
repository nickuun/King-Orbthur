extends Area2D

@export var delay_before_freeze := 1.5
var inside := false
var timer := 0.0

func _process(delta):
	if inside:
		timer += delta
		if timer >= delay_before_freeze:
			Game.freeze_orb()  # or emit a signal

func _on_body_entered(body):
	if body.is_in_group("Player"):
		inside = true
		timer = 0.0

func _on_body_exited(body):
	if body.is_in_group("Player"):
		inside = false
		timer = 0.0
