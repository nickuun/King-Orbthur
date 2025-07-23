extends CharacterBody2D

@export var max_speed: float = 100.0 #200
@export var accel: float = 800.0
@export var friction: float = 600.0
@export var max_health: int = 100
var current_health: int
@export var dash_speed: float = 0.0
@export var dash_duration: float = 0.2
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
@onready var sword = $Sword
var sword_desired_offset = -180
var sword_side = "left"
@onready var dust_spawn = $DustMarker
@onready var sprite = $AnimatedSprite2D
var last_frame = -1
var dust_scene = preload("res://Scenes&Scripts/Player/Dust/dust_trail.tscn")
var coin_count: int = 0
var coin_multiplier: int = 0
var is_hurting: bool = false
@export var autoplay: bool = false
@export var alive: bool = true
@export var dash_coyote_time: float = 0.15
var dash_coyote_timer: float = 0.0
@export var dash_directional_influence: float = 0.2
var active_temp_effects: Dictionary = {}



@export var dash_cooldown_duration: float = 0.5
var dash_cooldown_timer: float = 0.0

#var has_key := false
var key_count: int = 3

func swing_sword():
	if Game.orb and Game.orb.state == Game.orb.BallState.NORMAL:
		if sword_side == "left": 
			sword.get_node("Sprite").play("SwingRight")
			sword_desired_offset = 180
			sword_side = "right"
		else:
			sword.get_node("Sprite").play("SwingLeft")
			sword_side = "left"
			sword_desired_offset = -180
	else:
		print("⚠️ Can't swing — ball is frozen, returning, or gone.")

func add_coin():
	coin_count += coin_multiplier
	update_coin_ui()
	
func update_coin_ui():
	if Game.coin_label:
		Game.coin_label.text = str(coin_count)
		
func spawn_dust():
	if not is_instance_valid(dust_spawn):
		print("⚠️ No dust_spawn marker found!")
		return

	var dust = dust_scene.instantiate()

	if dust:
		dust.global_position = dust_spawn.global_position
		get_tree().current_scene.add_child(dust) # Use top-level node to avoid offset issues

func _ready():
	coin_multiplier = 1
	Game.orb = get_tree().get_first_node_in_group("Ball")  # now globally available
	Game.player = self
	Game.lifebar = get_tree().get_first_node_in_group("LifeBar")
	dash_speed = 2*max_speed
	current_health = max_health
	update_lifebar()

func _physics_process(delta):
	var is_moving = velocity.length() > 0.5

	if alive:
		dash_coyote_timer = max(dash_coyote_timer - delta, 0.0)

		dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)

		if is_dashing:
			sprite.play("dash")
		elif is_hurting:
			sprite.play("hurt")
		elif is_moving:
			sprite.play("walk")
			var current_frame = sprite.frame
			if current_frame != last_frame:
				if current_frame == 1 or current_frame == 3:
					spawn_dust()
				last_frame = current_frame
		else:
			sprite.play("idle")

		
		if is_dashing:
			var input_dir = Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			).normalized()
			
			var influence = input_dir * dash_speed * dash_directional_influence
			velocity = (dash_direction * dash_speed) + influence

			dash_timer -= delta
			if dash_timer <= 0.0:
				is_dashing = false
				dash_coyote_timer = dash_coyote_time

				
		if Input.is_action_just_pressed("dash") and not is_dashing:
			if dash_cooldown_timer > 0:
				print("⏳ dash on cooldown!")
			else:
				print("DASHING")
				var input_dir = Vector2(
					Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
					Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
				).normalized()

				if input_dir != Vector2.ZERO:
					dash_direction = input_dir
					is_dashing = true
					dash_timer = dash_duration
					dash_cooldown_timer = dash_cooldown_duration
					sprite.play("dash")



		var input_vector = Vector2.ZERO

		input_vector = Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			).normalized()

		if autoplay and Game.orb and  input_vector == Vector2.ZERO:
			var direction_y = sign(Game.orb.global_position.y - global_position.y)
			input_vector = Vector2(0, direction_y)

		if input_vector != Vector2.ZERO:
			velocity = velocity.move_toward(input_vector * max_speed, accel * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		
		move_and_slide()
		
			# Face the orb
		if Game.orb:
			sprite.flip_h = Game.orb.global_position.x < global_position.x

		
		if Game.orb:
			var to_orb = Game.orb.global_position - global_position
			if to_orb.length() > 1:
				var cock_angle = to_orb.angle() + PI  # Face opposite direction
				sword.rotation = cock_angle + sword_desired_offset + PI / 2

func apply_damage():
	if is_hurting:
		return  # Prevent overlapping damage animations

	is_hurting = true
	current_health -= 10
	print("💔 Took damage! Health:", current_health)
	update_lifebar()

	# Play hurt animation
	$AnimatedSprite2D.play("hurt")
	ScreenShakeManager.shake(0.5, 0.15)

	# Wait for hurt animation to finish
	await $AnimatedSprite2D.animation_finished

	is_hurting = false

	if current_health <= 0:
		game_over()


func apply_knockback(direction: Vector2, force: float):
	velocity += direction * force

func update_lifebar():
	Game.lifebar.update_health_bar(current_health, max_health)
	
func obtain_key():
	key_count += 1
	print("🔑 Key acquired! Now have", key_count, "keys.")
	
func collect_battle_pickup(pickup_type: String) -> void:
	var effect_data = Game.get_item_by_effect(pickup_type)
	if effect_data and pickup_type.begins_with("temp_"):
		Game.effect_manager.add_effect(pickup_type, effect_data.texture, 5.0)

	match pickup_type:
		"temp_ball_grow":
			apply_temporary_effect(
				"temp_ball_grow",
				5.0,
				func():
					var tween = Game.orb.create_tween()
					tween.tween_property(Game.orb, "scale", Vector2(2, 2), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT),
				func():
					var tween = Game.orb.create_tween()
					tween.tween_property(Game.orb, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			)
			
		"temp_player_grow":
			apply_temporary_effect(
				"temp_player_grow",
				5.0,
				func():
					var tween = create_tween()
					tween.tween_property(self, "scale", Vector2(2, 2), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT),
				func():
					var tween = create_tween()
					tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			)


		"temp_lifesteal":
			Game.lifesteal_enabled = true
			await get_tree().create_timer(5.0).timeout
			Game.lifesteal_enabled = false

		"temp_sword_grow":
			Game.player_sword.scale *= 2.0
			await get_tree().create_timer(5.0).timeout
			Game.player_sword.scale /= 2.0

		"perm_shop_discount":
			Game.shop_discount = 0.8  # 20% off

		_:
			# Handle existing pickups here (speed_up, ball_slow etc.)
			pass

func game_over():
	alive = false
	$Sword.hide()
	sprite.play("die")
	await get_tree().create_timer(1.5).timeout
	var game_over_screen = get_tree().get_first_node_in_group("GameOverScreen")
	game_over_screen.show_scores()

func apply_temporary_effect(effect_name: String, duration: float, apply_func: Callable, remove_func: Callable) -> void:
	# If already active, extend the duration
	if active_temp_effects.has(effect_name):
		var timer: SceneTreeTimer = active_temp_effects[effect_name]
		timer.time_left += duration
	else:
		# Apply the effect and create timer
		apply_func.call()
		var timer = get_tree().create_timer(duration)
		active_temp_effects[effect_name] = timer
		# Wait async
		await timer.timeout
		active_temp_effects.erase(effect_name)
		remove_func.call()
