extends Node2D

var restart_hold_time := 0.0
const HOLD_DURATION := 3.0


func _ready() -> void:

	Game.coin_label = get_tree().get_first_node_in_group("CoinLabel")


func _process(delta: float) -> void:
	if Input.is_action_pressed("restart"):
		restart_hold_time += delta
		if restart_hold_time >= HOLD_DURATION:
			restart_game()
	else:
		restart_hold_time = 0.0

func _input(event):
	if event.is_action_pressed("restart"):
		print("⏳ Holding R to restart...")
	if event.is_action_released("restart"):
		print("❌ Restart canceled")

func restart_game():
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path

	Game.should_keep_seed = false
	SeedManager.set_seed(SeedManager.generate_seed())

	get_tree().change_scene_to_file(scene_path)
