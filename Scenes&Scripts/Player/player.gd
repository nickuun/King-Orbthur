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
@export var autoplay: bool = true

var has_key := false

func swing_sword():
	if sword_side == "left": 
		sword.get_node("Sprite").play("SwingRight")
		sword_desired_offset = 180
		sword_side = "right"
	else:
		sword.get_node("Sprite").play("SwingLeft")
		sword_side = "left"
		sword_desired_offset = -180

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

	if !is_hurting:
		if is_moving and !is_dashing:
			sprite.play("walk")  # play walk only if moving
			var current_frame = sprite.frame
			if current_frame != last_frame:
				if current_frame == 1 or current_frame == 3:
					spawn_dust()
				last_frame = current_frame
		else:
			sprite.play("idle")
	else:
			sprite.play("hurt")
	
	if is_dashing:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	if Input.is_action_just_pressed("dash") and not is_dashing:
		print("DASHING")
		var input_dir = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		).normalized()

		if input_dir != Vector2.ZERO:
			dash_direction = input_dir
			is_dashing = true
			dash_timer = dash_duration


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
	has_key = true
	print("🔑 Key acquired!")
	
func collect_battle_pickup(pickup_type: String) -> void:
	match pickup_type:
		"heal":
			current_health = min(current_health + 10, max_health)
			update_lifebar()

		"speed_up":
			max_speed *= 1.5
			await get_tree().create_timer(5.0).timeout
			max_speed /= 1.5

		"speed_down":
			max_speed *= 0.5
			await get_tree().create_timer(5.0).timeout
			max_speed *= 2.0

		"ball_slow":
			Game.orb.ball_speed *= 0.5
			await get_tree().create_timer(5.0).timeout
			Game.orb.ball_speed *= 2.0

		"ball_damage_up":
			Game.orb.bounce_strength *= 2.0
			await get_tree().create_timer(5.0).timeout
			Game.orb.bounce_strength /= 2.0

		"double_coins":
			coin_multiplier = 2
			await get_tree().create_timer(5.0).timeout
			coin_multiplier = 1


func game_over():
	pass
