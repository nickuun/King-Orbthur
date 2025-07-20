extends Node2D

var restart_hold_time := 0.0
const HOLD_DURATION := 3.0
@export var ball_scene: PackedScene

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
	
func respawn_ball():
	# Clean up any existing ball if needed
	for ball in get_tree().get_nodes_in_group("Ball"):
		ball.queue_free()

	var spawn_point = get_tree().get_first_node_in_group("BallStartPos")
	if spawn_point:
		var ball = ball_scene.instantiate()
		ball.global_position = spawn_point.global_position
		get_tree().current_scene.add_child(ball)
		Game.orb = ball  # Save a reference if needed
		ball.respawn()
	else:
		push_error("❌ No BallStartPos found in group!")
