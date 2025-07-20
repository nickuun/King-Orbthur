extends Control
class_name PauseMenu

@onready var resume_button = $TextureButton
@onready var restart_button = $TextureButton2
@onready var volume_slider = $HSlider

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
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
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if self.visible:
			hide_menu()
		else:
			show_menu()
