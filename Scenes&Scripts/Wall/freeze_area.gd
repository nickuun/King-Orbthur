extends Area2D

@export var delay_before_freeze := 1.5
var inside := false
var timer := 0.0

func _process(delta):
	if inside:
		timer += delta
		if timer >= delay_before_freeze:
			if is_instance_valid(Game.orb) and Game.orb.state == Game.orb.BallState.FROZEN:
				Game.orb.return_to_player()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if is_instance_valid(Game.orb):
			Game.orb.freeze()
			inside = true
			timer = 0.0

func _on_body_exited(body):
	if body.is_in_group("Player"):
		if is_instance_valid(Game.orb) and Game.orb.state == Game.orb.BallState.FROZEN:
			Game.orb.unfreeze()
			inside = false
			timer = 0.0
