extends StaticBody2D

@onready var unlock_area := $UnlockArea
var is_unlocked := false

func _ready():
	unlock_area.connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node):
	if is_unlocked:
		return

	if body.name == "Ball" and Game.player.has_key:
		print("🔓 Unlocking door!")
		is_unlocked = true
		Game.player.has_key = false  # Consume key
		#$AnimatedSprite2D.play("unlock")  # Optional animation
		#await $AnimatedSprite2D.animation_finished
		get_tree().get_first_node_in_group("MiddleBoundry").unlock_boundary()
		queue_free()
