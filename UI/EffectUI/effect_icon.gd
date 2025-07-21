extends Control

@export var effect_name: String = ""
@export var duration: float = 5.0
@export var icon_texture: Texture2D
var remaining_time: float

var tween: Tween

@onready var timer_label: Label = $TimerLabel
@onready var icon_rect: Sprite2D = $Icon

func _ready():
	print("HELLO FROM ICON")
	remaining_time = duration
	icon_rect.texture = icon_texture
	tween = create_tween()

func _process(delta):
	remaining_time = max(remaining_time - delta, 0.0)
	timer_label.text = "%.1f" % remaining_time

	if remaining_time <= 0.0:
		queue_free()
		get_parent().call_deferred("reflow_icons")

func move_to(pos: Vector2):
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", pos, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func extend_duration(extra: float):
	duration += extra
	remaining_time += extra
