extends Area2D

@export var arc_height := randf_range(16, 24)
@export var lifetime := 10.0  # Extended from 8
@export var time_to_land := 0.3 + randf_range(-0.05, 0.05)
var held_by_ball: bool = false
var has_been_held: bool = false

var start_position := Vector2.ZERO
var target_position := Vector2.ZERO
var elapsed := 0.0
var landed := false

const FADE_DURATION := 2.0
var fade_timer := 0.0

@onready var sprite := $AnimatedSprite2D

func _ready():
	sprite.play("spin")
	sprite.speed_scale = randf_range(0.8, 1.2)

	connect("body_entered", _on_body_entered)
	set_process(true)
	modulate.a = 1.0  # Fully visible

func _process(delta):
	if not landed:
		elapsed += delta
		var t = clamp(elapsed / time_to_land, 0.0, 1.0)
		var height = -4 * arc_height * t * (t - 1.0)
		global_position = start_position.lerp(target_position, t) + Vector2(0, -height)

		if t >= 1.0:
			landed = true
			$CollisionShape2D.set_deferred("disabled", false)
	else:
		# Pause decay if held
		if held_by_ball:
			return
		if !has_been_held:
			lifetime -= delta

		# Begin fading out when lifetime runs low
		if lifetime <= FADE_DURATION and !has_been_held:
			fade_timer += delta
			var fade_t = clamp(fade_timer / FADE_DURATION, 0.0, 1.0)

			# Speed up spin & fade out
			sprite.speed_scale = lerp(sprite.speed_scale, 3.5, fade_t)
			modulate.a = 1.0 - fade_t

		if lifetime <= 0.0 and !has_been_held:
			queue_free()

func _on_body_entered(body):
	if held_by_ball:
		return
	if body == Game.player:
		Game.player.add_coin()
		queue_free()

func launch_to(target: Vector2):
	start_position = global_position
	target_position = target
	elapsed = 0.0
	landed = false
	fade_timer = 0.0
	modulate.a = 1.0
	sprite.speed_scale = randf_range(0.8, 1.2)
	$CollisionShape2D.set_deferred("disabled", true)
