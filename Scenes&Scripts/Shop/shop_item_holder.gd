extends Area2D

var item_data := {}  # We'll assign this dynamically

var purchased := false
var ready_for_purchase := false

func setup(item: Dictionary):
	print("setting up shop item")
	item_data = item
	$Sprite2D.texture = item.texture
	$PriceLabel.text = str(item.price)

func _process(_delta):
	if ready_for_purchase and Input.is_action_just_pressed("interact"):
		print("TRYING TO BUY")
		if Game.player.coin_count >= item_data.price:
			print("PURCHASED ")
			Game.player.coin_count -= item_data.price
			Game.player.update_coin_ui()
			purchased = true
			$PriceLabel.hide()
			spawn_real_item()
		else:
			print("Too poor")

func _on_body_entered(body):
	if body.is_in_group("Player") and not purchased:
		ready_for_purchase = true
	var popup = get_tree().get_first_node_in_group("ItemPopup")
	if popup:
		popup.show_item(item_data)  # Pass your item dictionary

func _on_body_exited(body):
	if body.is_in_group("Player"):
		ready_for_purchase = false
	var popup = get_tree().get_first_node_in_group("ItemPopup")
	if popup:
		popup.hide_popup()

func spawn_real_item():
	var real_item = item_data.scene.instantiate()
	real_item.pickup_type = item_data.effect
	real_item.skip_launch = true
	real_item.position = self.position
	get_parent().add_child(real_item)
	#real_item.global_position = global_position
	queue_free()
