extends RigidBody2D

@export var hit_points: int = 5
signal brick_destroyed(brick: Node)
var stage_index: int = -1  # Default to invalid

var coin_scene = preload("res://Scenes&Scripts/Coin/coin.tscn")

var chest_variant := 1  # Range 1–9

func _ready():
	chest_variant = SeedManager.randi_range(1, 9)
	$AnimatedSprite2D.animation = "chest_%d" % chest_variant
	$AnimatedSprite2D.frame = 0  # Show closed state only

func _on_hit():
	hit_points -= 1

	if hit_points <= 0:
		$CollisionShape2D.disabled = true

		# Play full open animation
		$AnimatedSprite2D.play("chest_%d" % chest_variant)
		await $AnimatedSprite2D.animation_finished

		# 🎁 Drop 3–6 coins with a satisfying pop!
		for i in range(SeedManager.randi_range(3, 6)):
			var coin = coin_scene.instantiate()
			get_tree().current_scene.add_child(coin)
			coin.global_position = global_position
			var offset = Vector2(randf_range(-32, 32), randf_range(-20, -40))
			coin.launch_to(global_position + offset)

		emit_signal("brick_destroyed", self)
		get_tree().get_first_node_in_group("ScoreLabel").add_points(10)
		Game.show_floating_text("+10", global_position, Color.YELLOW, 18, 1.6)

		await get_tree().create_timer(0.1).timeout
		queue_free()
	else:
		# 🌀 Squash/stretch on hit
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector2(1, 1), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
