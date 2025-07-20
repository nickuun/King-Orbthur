extends Area2D

@export var pull_speed := 40.0
@export var target_position := Vector2.ZERO  # Fallback if no player found

var tracked_pickups := []

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)

func _on_area_entered(area):
	if area.is_in_group("pickup") and not tracked_pickups.has(area):
		tracked_pickups.append(area)
		print("🧲 RescueZone: Tracking", area.name)

func _on_area_exited(area):
	if tracked_pickups.has(area):
		tracked_pickups.erase(area)
		print("🧲 RescueZone: Released", area.name)

func _process(delta):
	# Determine safe target — usually player
	var safe_target = Game.player.global_position if is_instance_valid(Game.player) else target_position

	# Gently pull tracked pickups toward target
	for item in tracked_pickups:
		if not is_instance_valid(item):
			continue  # Cleanup invalid references

		var direction = (safe_target - item.global_position).normalized()
		item.global_position += direction * pull_speed * delta
