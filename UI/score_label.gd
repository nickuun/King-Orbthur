extends Node

@export var score_label: Label
@export var points_per_brick := 5
var score := 100
var displayed_score := 0

func _ready():
	score_label.text = str(score)

func add_points(amount: int):
	score += amount
	animate_score()
	pulse_label()

func animate_score():
	var tween := create_tween()
	tween.tween_method(_update_displayed_score, displayed_score, score, 0.3)

func _update_displayed_score(value: float):
	displayed_score = int(value)
	score_label.text = str(displayed_score)

func pulse_label():
	var tween := create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(score_label, "scale", Vector2(1, 1), 0.1).set_delay(0.1)
