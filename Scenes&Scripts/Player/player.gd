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
var coin_count: int = 100
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

var active_item: ActiveItem = null
@export var max_active_charge: int = 3

#var has_key := false
var key_count: int = 3

func assign_active_item(new_item: ActiveItem):
	if active_item and active_item != new_item:
		var drop_pos = global_position + Vector2(0, -16)
		active_item.reparent(get_tree().current_scene)
		active_item.set_equipped(false)  # Show it again
		active_item.launch_to(drop_pos)
		

	active_item = new_item
	add_child(active_item)
	active_item.set_equipped(true)  # Hide while equipped
	print("🎮 Assigned active item:", active_item.item_name)

func swing_sword():
	$Sword.swing_sword()

func add_coin():
	coin_count += coin_multiplier
	Game.update_coin_ui(coin_count)
		
func spawn_dust():
	if not is_instance_valid(dust_spawn):
		print("⚠️ No dust_spawn marker found!")
		return

	var dust = dust_scene.instantiate()

	if dust:
		dust.global_position = dust_spawn.global_position
		get_tree().current_scene.add_child(dust) # Use top-level node to avoid offset issues

func _ready():
	var test_item := preload("res://Scenes&Scripts/Pickups/Items/active_item.tscn").instantiate()
	test_item.item_name = "Speed Burst"
	test_item.effect_name = "active_orb_grow"
	test_item.icon = preload("res://Sprites/Items/CustomIcons15.png")
	test_item.max_charges = 3
	assign_active_item(test_item)
	
	coin_multiplier = 1
	Game.orb = get_tree().get_first_node_in_group("Ball")  # now globally available
	Game.player = self
	Game.lifebar = get_tree().get_first_node_in_group("LifeBar")
	dash_speed = 2*max_speed
	current_health = max_health
	update_lifebar()

func _physics_process(delta):
	if Input.is_action_just_pressed("activate_item") and active_item:
		active_item.try_activate()

	
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
			var input_dir = InputManager.get_movement_vector()
			
			var influence = input_dir * dash_speed * dash_directional_influence
			velocity = (dash_direction * dash_speed) + influence

			dash_timer -= delta
			if dash_timer <= 0.0:
				is_dashing = false
				dash_coyote_timer = dash_coyote_time
				
		if InputManager.is_dash_pressed() and not is_dashing:
			if dash_cooldown_timer > 0:
				print("⏳ dash on cooldown!")
			else:
				print("DASHING")
				var input_dir = InputManager.get_movement_vector()

				if input_dir != Vector2.ZERO:
					dash_direction = input_dir
					is_dashing = true
					dash_timer = dash_duration
					dash_cooldown_timer = dash_cooldown_duration
					sprite.play("dash")

		var input_vector = Vector2.ZERO

		input_vector = InputManager.get_movement_vector()

		if autoplay and Game.orb and  input_vector == Vector2.ZERO:
			var direction_y = sign(Game.orb.global_position.y - global_position.y)
			input_vector = Vector2(0, direction_y)

		if input_vector != Vector2.ZERO:
			velocity = velocity.move_toward(input_vector * get_speed(), accel * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		move_and_slide()
		
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
	BattlePickupManager.apply(pickup_type, self)

func game_over():
	alive = false
	$Sword.hide()
	sprite.play("die")
	await get_tree().create_timer(1.5).timeout
	var game_over_screen = get_tree().get_first_node_in_group("GameOverScreen")
	game_over_screen.show_scores()

func get_speed() -> float:
	return StatsManager.get_final_player_speed()

func apply_temporary_effect(
	effect_name: String,
	duration: float,
	start_func: Callable,
	end_func: Callable
) -> void:
	# If already active, extend duration
	if Game.active_temp_effects.has(effect_name):
		var data = Game.active_temp_effects[effect_name]
		if data.has("timer") and is_instance_valid(data["timer"]):
			var timer: Timer = data["timer"]
			timer.start(duration)
			return

	# Not active: apply effect
	start_func.call()

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	timer.name = "temp_timer_" + effect_name
	add_child(timer)

	# Store the effect
	Game.active_temp_effects[effect_name] = {
		"timer": timer,
		"end_func": end_func
	}

	timer.connect("timeout", Callable(self, "_on_temp_effect_timeout").bind(effect_name))
	timer.start()

func _on_temp_effect_timeout(effect_name: String) -> void:
	if Game.active_temp_effects.has(effect_name):
		var data = Game.active_temp_effects[effect_name]
		var end_func: Callable = data.get("end_func")
		if end_func:
			end_func.call()
		data["timer"].queue_free()
		Game.active_temp_effects.erase(effect_name)
