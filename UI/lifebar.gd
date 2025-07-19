extends TextureProgressBar

var green_texture = preload("res://Sprites/Healthbar/GreenUnder.png")
var orange_texture = preload("res://Sprites/Healthbar/OrangeUnder.png")
var red_texture = preload("res://Sprites/Healthbar/RedUnder.png")

func update_health_bar(current: int, max: int):
	var percent := float(current) / max * 100.0
	value = percent

	# Change bar color
	if percent <= 33:
		texture_progress = red_texture
	elif percent <= 66:
		texture_progress = orange_texture
	else:
		texture_progress = green_texture
