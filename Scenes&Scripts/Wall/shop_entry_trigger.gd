extends Area2D

@export var shop_camera_target: Node2D  # an invisible node at the center of the shop area
var is_inside_shop: bool = false

func _on_body_entered(body):
	
	if body.is_in_group("Player"):
		move_camera()
		is_inside_shop =  !is_inside_shop
		if is_inside_shop:
			handle_shop_enter()
		else:
			handle_shop_exit()
		
func move_camera():
		print("Player trigger camera move")
		var camera = get_tree().get_first_node_in_group("Camera")
		if camera:
			camera.global_position = shop_camera_target.global_position
			Game.player.position.x += 20

func handle_shop_enter():
	print("ENTERING THE SHOP -> SHOWING SHOP")
	var shop = get_tree().get_first_node_in_group("Shop")
	shop.show()
	
func handle_shop_exit():
	var shop = get_tree().get_first_node_in_group("Shop")
	shop.queue_free()
	
	var mid = get_tree().get_first_node_in_group("MiddleBoundry")
	mid.lock_boundary()
	var brick_manager = get_tree().get_first_node_in_group("BrickManager")
	if brick_manager:
		brick_manager.reset_level()
