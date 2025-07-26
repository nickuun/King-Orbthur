extends Area2D

var item_data := {}
var purchased := false
var ready_for_purchase := false

@onready var price_label := $PriceLabel
@onready var sprite := $Sprite2D

func setup(item: Dictionary):
	print("🛍️ Setting up shop item:", item.name)
	item_data = item

	var sprite_node = get_node_or_null("Sprite2D")
	var label_node = get_node_or_null("PriceLabel")

	if sprite_node and item.has("texture"):
		sprite_node.texture = item.texture
	if label_node:
		label_node.text = str(item.price)

func _process(_delta):
	if ready_for_purchase and Input.is_action_just_pressed("interact"):
		if Game.player.coin_count >= item_data.price:
			print("💰 Purchased", item_data.name)
			Game.player.coin_count -= item_data.price
			Game.update_coin_ui(Game.player.coin_count)
			purchased = true
			price_label.hide()
			spawn_real_item()
		else:
			print("🚫 Not enough coins")

func _on_body_entered(body):
	if body.is_in_group("Player") and not purchased:
		ready_for_purchase = true
	var popup = get_tree().get_first_node_in_group("ItemPopup")
	if popup:
		popup.show_item(item_data)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		ready_for_purchase = false
	var popup = get_tree().get_first_node_in_group("ItemPopup")
	if popup:
		popup.hide_popup()

func spawn_real_item():
	if item_data.has("type") and item_data.type == "active":
		var active_item_scene = preload("res://Scenes&Scripts/Pickups/Items/active_item.tscn")
		var item_instance = active_item_scene.instantiate()

		item_instance.item_name = item_data.name
		item_instance.icon = item_data.texture
		item_instance.effect_name = item_data.effect
		item_instance.flavour = item_data.flavour
		item_instance.effect_duration = item_data.get("duration", 3.0)
		item_instance.max_charges = item_data.get("max_charges", 4)
		item_instance.current_charges = item_instance.max_charges

		item_instance.global_position = global_position
		get_tree().current_scene.add_child(item_instance)

	else:
		# Fallback: Battle pickup (default)
		var pickup = item_data.scene.instantiate()
		pickup.pickup_type = item_data.effect
		pickup.skip_launch = true
		pickup.global_position = global_position
		get_tree().current_scene.add_child(pickup)

	queue_free()
