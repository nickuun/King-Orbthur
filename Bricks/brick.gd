extends RigidBody2D

var coin_scene = preload("res://Scenes&Scripts/Coin/coin.tscn")
@export var hit_points: int = 1
signal brick_destroyed(brick: Node)
var stage_index: int = -1  # Default to invalid

var drops_key: bool = false

var variant := 1
var variant_hp := {
	1: 1,
	2: 2,
	3: 3
}

func _ready():
	# Randomly pick a variant (1, 2, or 3)
	variant = SeedManager.randi_range(1, 3)
	
	hit_points = variant_hp[variant]
	$AnimatedSprite2D.play("box%d" % variant)

func _on_hit():
	print("💥 Brick hit at stage index:", stage_index)
	
	
	## 💰 Guaranteed coin drop if effect active
	if Game.has_temp_effect("temp_coin_hit"):
		var coin = coin_scene.instantiate()
		get_tree().current_scene.add_child(coin)
		coin.global_position = global_position
		var offset = Vector2(randf_range(-24, 24), randf_range(-16, -24))
		coin.launch_to(global_position + offset)

	hit_points -= 1

	if hit_points <= 0:
		$CollisionShape2D.disabled = true
		$AnimatedSprite2D.play("box%d_break" % variant)
		await $AnimatedSprite2D.animation_finished

		# 💰 Spawn a coin with an arc!
		var coin = coin_scene.instantiate()
		get_tree().current_scene.add_child(coin)
		coin.global_position = global_position
		var offset = Vector2(randf_range(-24, 24), randf_range(-16, -24))
		coin.launch_to(global_position + offset)
		
				# 🗝️ Drop a key if this brick was marked
		if drops_key:
			print("🗝️ Dropped key!")
			var key = preload("res://Scenes&Scripts/Key/key.tscn").instantiate()
			print("dropped key")
			get_tree().current_scene.add_child(key)
			key.global_position = global_position
			var offs = Vector2(randf_range(-24, 24), randf_range(-24, -40))
			key.launch_to(global_position + offset)
		
		#if SeedManager.randf() <= 0.1:
		if SeedManager.randf() <= 1.0:
		
			var battle_pickup = preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn").instantiate()
			battle_pickup.pickup_type = pick_random_type()
			get_tree().current_scene.add_child(battle_pickup)
			battle_pickup.global_position = global_position
			var offse = Vector2(randf_range(-16, 16), randf_range(-24, -32))
			battle_pickup.launch_to(global_position + offset)


		emit_signal("brick_destroyed", self)
		get_tree().get_first_node_in_group("ScoreLabel").add_points(5)
		Game.show_floating_text("+5", global_position, Color.GOLD, 16, 1.4)
		await get_tree().create_timer(0.05).timeout  # ⏳ Tiny delay before cleanup
		queue_free()
	else:
		# Play hit animation if still alive
		$AnimatedSprite2D.play("box%d_hit" % variant)
		await $AnimatedSprite2D.animation_finished

		# Return to idle after hurt
		$AnimatedSprite2D.play("box%d" % variant)

func pick_random_type() -> String:
	var options = ["heal", "temp_speed_up", "temp_ball_slow", "temp_coin_hit", "temp_player_grow", "temp_coin_hit", "temp_ball_grow"]
	#var options = ["temp_coin_hit"]
	return options[randi() % options.size()]
