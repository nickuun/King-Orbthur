extends Control
class_name PauseMenu

@onready var resume_button = $TextureButton
@onready var restart_button = $TextureButton2
@onready var restart_with_seed_button = $RestartWithSeedButton
@onready var volume_slider = $HSlider

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	restart_with_seed_button.pressed.connect(_on_restart_with_seed_pressed)
	
	volume_slider.value_changed.connect(_on_volume_changed)
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, false) # Ensure unfiltered at start
	visible = false

func show_menu():
	visible = true
	get_tree().paused = true
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, true) # Enable muffling

func hide_menu():
	visible = false
	get_tree().paused = false
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, false) # Disable muffling

func _on_resume_pressed():
	hide_menu()

func _on_restart_pressed():
	print("RESTART WITH NEW SEED PRESSED")
	get_tree().paused = false
	Game.should_keep_seed = false
	get_tree().get_first_node_in_group("World").restart_game()

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if self.visible:
			hide_menu()
		else:
			show_menu()

func _on_restart_with_seed_pressed():
	print("RESTART WITH SAME SEED PRESSED")
	Game.should_keep_seed = true
	get_tree().paused = false
	get_tree().get_first_node_in_group("World").restart_game()
