extends Area2D

func is_clear() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			return false
	return true
