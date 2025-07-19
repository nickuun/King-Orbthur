extends CharacterBody2D

@export var ball_speed: float = 180.0#200
@export var knockback_force: float = 400.0
@export var bounce_strength: float = 1.0
var should_respawn := false
var held_coins: Array = []
var returning := false
@export var shrink_speed := 2.0

func _ready():
		# Detect coin contact
	$CoinArea.connect("area_entered", _on_coin_area_entered)
	$ProximityArea.body_entered.connect(_on_proximity_body_entered)

func freeze_and_return_to_player():
	returning = true
	#mode = RigidBody2D.MODE_KINEMATIC
	set_process(true)

func _on_coin_area_entered(area: Area2D):
	if area.is_in_group("pickup") and not area.held_by_ball:
		area.held_by_ball = true
		area.has_been_held = true
		held_coins.append(area)
		area.hide()  # Hide until it's dropped off

func _on_proximity_body_entered(body):
	if body.is_in_group("Player"):
		if Game.player.is_dashing:
			freeze_time()
		Game.player.swing_sword()
		
		var direction = (global_position - body.global_position).normalized()
		var knock_dir: Vector2

		if velocity.length() > 0.1:
			# Ball already moving — knock player in ball's current direction
			knock_dir = velocity.normalized()
		else:
			# Ball was idle — knock player away from hit direction
			knock_dir = (body.global_position - global_position).normalized()

		velocity = direction * ball_speed
		Game.player.apply_knockback(knock_dir, 100)
		
			# Drop off any coins held by the ball
		for coin in held_coins:
			if is_instance_valid(coin):
				coin.held_by_ball = false  # It can now be picked up
				coin.global_position = self.global_position
				coin.show()  # Make visible again! 
				coin.modulate = Color(1,1,1,1)  # Fully visible

				## Optionally re-enable collision in case it's still disabled
				#if coin.has_node("CollisionShape2D"):
					#coin.get_node("CollisionShape2D").disabled = true  # Ensure re-disabled during relaunch

				# Relaunch from the ball to the player with a bounce arc
				var drop_offset = Vector2(randf_range(-32, 32), randf_range(-20, -40))
				coin.launch_to(Game.player.global_position + drop_offset)


		held_coins.clear()

func _physics_process(delta: float) -> void:
	if returning:
		global_position = global_position.lerp(Game.player.global_position, 3.0 * delta)
		scale = scale.lerp(Vector2.ZERO, shrink_speed * delta)
		
		if global_position.distance_to(Game.player.global_position) < 6:
			queue_free()  # or hide
			Game.on_orb_collected()
	
	if velocity.length() == 0:
		return

	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal).normalized() * ball_speed

		# Check for bricks
		if collider.is_in_group("brick") and collider.has_method("_on_hit"):
			collider._on_hit()

func respawn():
	var spawn_node = get_tree().get_first_node_in_group("BallStartPos")
	if not spawn_node:
		push_error("No BallStartPos in group!")
		return

	if spawn_node.is_clear():
		print("✅ Respawning ball")
		global_position = spawn_node.global_position
		velocity = Vector2.ZERO
		should_respawn = false
	else:
		print("⛔ Player in the way — queuing respawn")
		should_respawn = true
		spawn_node.connect("body_exited", Callable(self, "_on_respawn_area_cleared"), CONNECT_ONE_SHOT)

func _on_back_wall_body_entered(body: Node2D) -> void:
	if body.is_in_group("Damage"):
		print("Applying damage")
		Game.player.apply_damage()
	respawn()

func _on_ball_start_pos_body_exited(body: Node2D) -> void:
	if should_respawn and body.is_in_group("Player"):
		respawn()
		
func freeze_time():
	var timer := get_tree().create_timer(0.05, true)  # true = real-time, ignores time_scale
	Engine.time_scale = 0.1
	await timer.timeout
	Engine.time_scale = 1.0
