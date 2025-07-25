extends Node


func play_squash(node: Node2D, direction: Vector2) -> void:
	var sprite := node.get_node_or_null("Sprite2D")
	if not sprite: return

	var base_scale := Vector2.ONE
	var squash_scale := Vector2(1.2, 0.8)

	var angle := direction.angle()
	var stretch_x := cos(angle)
	var stretch_y := sin(angle)

	var squash := Vector2(
		lerp(base_scale.x, squash_scale.x, abs(stretch_x)),
		lerp(base_scale.y, squash_scale.y, abs(stretch_y))
	)

	sprite.scale = squash
	var tween := node.create_tween()
	tween.tween_property(sprite, "scale", base_scale, 0.12).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
