extends Control
class_name GameOverScreen

@onready var score_label = $ScoreLabel
#@onready var highscore_label = $VBoxContainer/HighscoreLabel
@onready var retry_button = $TextureButton
@onready var highscore_label = $HighscoreLabel

func _ready():
	retry_button.pressed.connect(_on_retry_pressed)
	visible = false

func show_scores(score: int = 10):
	var s = get_tree().get_first_node_in_group("ScoreLabel").score
	score_label.text = "Score: " + str(s)

	if s > Game.highscore:
		Game.highscore = s
		Game.save_highscore()

	highscore_label.text = "High Score: " + str(Game.highscore)
	visible = true

func _on_retry_pressed():
	get_tree().reload_current_scene()
