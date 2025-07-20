extends CharacterBody2D

@export var ball_speed: float = 180.0#200
@export var knockback_force: float = 400.0
@export var bounce_strength: float = 1.0
var should_respawn := false
var held_coins: Array = []
var returning := false
@export var shrink_speed := 2.0
var frozen := false
var previous_velocity = Vector2.ZERO

func _ready():
		# Detect coin contact
	var spawn_node = get_tree().get_first_node_in_group("BallStartPos")
	if spawn_node:
		if not spawn_node.is_connected("body_exited", Callable(self, "_on_ball_start_pos_body_exited")):
			spawn_node.connect("body_exited", Callable(self, "_on_ball_start_pos_body_exited"))
	
	var back_wall = get_tree().get_first_node_in_group("BackWall")

	if is_instance_valid(back_wall):
		if not back_wall.is_connected("body_entered", Callable(self, "_on_back_wall_body_entered")):
			back_wall.connect("body_entered", Callable(self, "_on_back_wall_body_entered"))
	else:
		print("⚠️ BackWall not found during _ready, deferring connection...")
		call_deferred("_connect_back_wall")
	
	$CoinArea.connect("area_entered", _on_coin_area_entered)
	$ProximityArea.body_entered.connect(_on_proximity_body_entered)

func freeze():
	previous_velocity = velocity
	frozen = true
	
func unfreeze():
	velocity = previous_velocity
	frozen = false

func return_to_player():
	returning = true
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

		var knock_dir = Vector2.ZERO
		var to_ball = (global_position - body.global_position).normalized()

		var player_velocity = body.velocity.normalized()
		var ball_velocity = velocity.normalized()

		var influence_factor = 0.4  # Controls how much player velocity affects the ball
		var bounce_factor = 0.2     # How much original knock_dir matters
		
		if Game.player.is_dashing:
			influence_factor = 0.9  # reward aggressive precision
			bounce_factor = 0.3     # still retain a bit of bounce control

		if velocity.length() > 0.1:
			# Ball already moving — preserve some of its direction
			knock_dir = (ball_velocity * 0.4 + to_ball * 0.6).normalized()
		else:
			# Ball was idle — player influence more important
			knock_dir = (to_ball * bounce_factor + player_velocity * influence_factor).normalized()

		var actual_speed = ball_speed * StatsManager.ball_speed_multiplier
		velocity = knock_dir * actual_speed

		Game.player.apply_knockback(-knock_dir, 100)

		# Drop off coins...
		for coin in held_coins:
			if is_instance_valid(coin):
				coin.held_by_ball = false
				coin.global_position = global_position
				coin.show()
				coin.modulate = Color(1, 1, 1, 1)
				var drop_offset = Vector2(randf_range(-32, 32), randf_range(-20, -40))
				coin.launch_to(Game.player.global_position + drop_offset)

		held_coins.clear()

func _physics_process(delta: float) -> void:
	if !frozen:
		if velocity.length() == 0:
			return
		
		var actual_speed = ball_speed * StatsManager.ball_speed_multiplier
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			var normal = collision.get_normal()
			velocity = velocity.bounce(normal).normalized() * actual_speed

			# Check for bricks
			if collider.is_in_group("brick") and collider.has_method("_on_hit"):
				collider._on_hit()
	else:
		if returning:
			global_position = global_position.lerp(Game.player.global_position, 3.0 * delta)
			#scale = scale.lerp(Vector2.ZERO, shrink_speed * delta)
			
			if global_position.distance_to(Game.player.global_position) < 6:
				queue_free()  # or hide
				Game.on_orb_collected()
		
		else:
			velocity = Vector2.ZERO

func respawn():
	print("respawn ball triggered")
	returning = false
	
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
	print("Bpdy exited")
	if should_respawn and body.is_in_group("Player"):
		respawn()
		
func freeze_time():
	var timer := get_tree().create_timer(0.05, true)  # true = real-time, ignores time_scale
	Engine.time_scale = 0.1
	await timer.timeout
	Engine.time_scale = 1.0
