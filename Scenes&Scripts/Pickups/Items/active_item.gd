extends Area2D
class_name ActiveItem

@export var item_name: String = "Default Active"
@export var icon: Texture
@export var max_charges: int = 3
@export var current_charges: int = 3
@export var cooldown: float = 0.0
@export var flavour: String = "A cool effect!"
@export var effect_name: String = "active_default"
@export var show_effect_in_ui: bool = true
@export var effect_duration: float = 3.0
@export var sprite_node: NodePath = "AnimatedSprite2D"

var is_on_cooldown := false

@onready var sprite := get_node(sprite_node)

func _ready():
	add_to_group("ActiveItem")
	if icon and sprite:
		sprite.texture = icon
	# Accept pickup
	connect("body_entered", _on_body_entered)

func set_equipped(is_equipped: bool):
	visible = not is_equipped

func try_activate():
	if is_on_cooldown:
		print("⏳", item_name, "is on cooldown!")
		return
	if current_charges < max_charges:
		print("🪫", item_name, "not fully charged! (", current_charges, "/", max_charges, ")")
		return

	current_charges = 0
	print("✅ Activated:", item_name)

	# UI effect manager call
	if Game.effect_manager and show_effect_in_ui:
		Game.effect_manager.add_effect(effect_name, icon, effect_duration, flavour)

	# Run effect logic
	_on_activate()

	if cooldown > 0:
		is_on_cooldown = true
		var cd_timer := Timer.new()
		cd_timer.one_shot = true
		cd_timer.wait_time = cooldown
		add_child(cd_timer)
		cd_timer.connect("timeout", Callable(self, "_on_cooldown_done"))
		cd_timer.start()

func _on_cooldown_done():
	is_on_cooldown = false

func add_charge(amount: int = 1):
	current_charges = clamp(current_charges + amount, 0, max_charges)

func is_ready_to_use() -> bool:
	return current_charges == max_charges and not is_on_cooldown

# Drop logic
func launch_to(target := Vector2.ZERO):
	var start_position := global_position

	# 🎯 Generate a random angle either left or right
	var base_angle := randf_range(-PI / 4, PI / 4)
	var flip := bool(randi() % 2)
	var final_angle := base_angle if not flip else base_angle + PI

	var launch_distance := randf_range(48, 72)
	var direction := Vector2.RIGHT.rotated(final_angle)
	var randomized_target := start_position + direction * launch_distance

	var time_to_land := 0.5 + randf_range(-0.05, 0.05)
	var arc_height := randf_range(16, 24)

	# 🌟 Make visible and disable collisions during flight
	modulate.a = 1.0
	$CollisionShape2D.set_deferred("disabled", true)

	# 🎞️ Tween arc motion
	var tween := create_tween()
	tween.tween_method(func(t):
		var height = -4 * arc_height * t * (t - 1.0)
		global_position = start_position.lerp(randomized_target, t) + Vector2(0, -height)
		if t >= 1.0:
			$CollisionShape2D.set_deferred("disabled", false)
	, 0.0, 1.0, time_to_land)


# Pickup behavior
func _on_body_entered(body):
	if body == Game.player:
		Game.player.assign_active_item(self)

func _on_activate():
	match effect_name:
		"active_orb_grow":
			var tween = Game.orb.create_tween()
			tween.tween_property(Game.orb, "scale", Vector2(2, 2), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await get_tree().create_timer(effect_duration).timeout
			var tween_out = Game.orb.create_tween()
			tween_out.tween_property(Game.orb, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

		"active_speed_boost":
			StatsManager.player_speed_multiplier *= 2.0
			await get_tree().create_timer(effect_duration).timeout
			StatsManager.player_speed_multiplier /= 2.0

		_:
			print("⚠️ No effect logic defined for:", effect_name)
