extends Node

class ShakeData:
	var strength = 0.0
	var frequency = 1.0
	var time_left = 0.0

var active_shakes: Array[ShakeData] = []
var camera: Camera2D = null
var default_offset := Vector2.ZERO

func _ready():
	_find_camera()

func _process(delta):
	if camera == null:
		_find_camera()

	if camera == null or active_shakes.is_empty():
		return

	# Clean up expired shakes
	active_shakes = active_shakes.filter(func(sd): return sd.time_left > 0)
	if active_shakes.is_empty():
		camera.offset = default_offset
		return

	# Apply combined shake effect
	var total_offset = Vector2.ZERO
	for shake in active_shakes:
		total_offset += Vector2(
			randf_range(-shake.strength, shake.strength),
			randf_range(-shake.strength, shake.strength)
		)
		shake.time_left -= delta

	camera.offset = total_offset / active_shakes.size()

func shake(strength := 5.0, duration := 0.2, frequency := 1.0):
	var shake_data = ShakeData.new()
	shake_data.strength = strength
	shake_data.frequency = frequency
	shake_data.time_left = duration
	active_shakes.append(shake_data)

func _find_camera():
	camera = get_tree().get_first_node_in_group("Camera")
