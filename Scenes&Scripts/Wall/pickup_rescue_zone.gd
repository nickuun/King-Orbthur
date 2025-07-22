extends Area2D

@export var pull_speed := 40.0
@export var target_position := Vector2.ZERO  # Fallback if no player found

@export_enum("up", "down", "left", "right") var pull_direction := "up"

var tracked_pickups := []



func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)

func _on_area_entered(area):
	if area.is_in_group("pickup") and not tracked_pickups.has(area):
		tracked_pickups.append(area)
		#print("🧲 RescueZone: Tracking", area.name)

func _on_area_exited(area):
	if tracked_pickups.has(area):
		tracked_pickups.erase(area)
		#print("🧲 RescueZone: Released", area.name)

func _process(delta):
	var direction := Vector2.ZERO

	if pull_direction == "up":
		direction = Vector2.UP
	elif pull_direction == "down":
		direction = Vector2.DOWN
	elif pull_direction == "left":
		direction = Vector2.LEFT
	elif pull_direction == "right":
		direction = Vector2.RIGHT

	for item in tracked_pickups:
		if not is_instance_valid(item):
			continue
		item.global_position += direction * pull_speed * delta
