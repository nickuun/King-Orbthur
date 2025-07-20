extends StaticBody2D

@onready var unlock_area := $UnlockArea
var shop_scene = preload("res://Scenes&Scripts/Shop/shop_area.tscn")
var is_unlocked := false

func _ready():
	unlock_area.connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node):
	if is_unlocked:
		return
		
		
	#if body.name == "Ball":
	if body.name == "Ball" and Game.player.key_count > 0:
		print("🔓 Unlocking door!")
		is_unlocked = true
		Game.player.key_count -= 1
		#$AnimatedSprite2D.play("unlock")  # Optional animation
		#await $AnimatedSprite2D.animation_finished
		get_tree().get_first_node_in_group("MiddleBoundry").unlock_boundary()
		var shop = shop_scene.instantiate()
		get_tree().current_scene.add_child(shop)
		shop.global_position = $SpawnSpot.global_position
		queue_free()
