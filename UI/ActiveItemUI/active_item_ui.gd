extends Control

@export var notch_texture: Texture2D
@export var max_width: int = 30
@export var spacing: int = 2

@onready var icon := $ItemIcon
@onready var charge_bar := $ChargeBar
@onready var notch_holder := $NotchHolder

var held_item: ActiveItem = null

func _ready():
	Game.active_item_ui = self
	clear_ui()

func clear_ui():
	#icon.texture = null
	$ChargeBar.value = 0
	$ChargeBar.max_value = 1
	for child in $NotchHolder.get_children():
		child.queue_free()

func assign_active_item(item: ActiveItem):
	print("ACTIVE ITEM UI TRIGGERED")
	clear_ui()

	if not item:
		return

	held_item = item
	$ItemIcon.texture = item.icon
	$ChargeBar.max_value = item.max_charges
	$ChargeBar.value = item.current_charges

	create_notches(item.max_charges)

func update_charge_display():
	if held_item:
		charge_bar.value = held_item.current_charges

func create_notches(count: int):
	if count <= 1:
		return

	await get_tree().process_frame  # Wait for bar sizing to settle if freshly assigned

	var bar_width = charge_bar.get_size().x
	var fill_start = charge_bar.get_global_position().x
	var fill_end = fill_start + bar_width
	var fill_range = fill_end - fill_start

	var notch_width = notch_texture.get_width()

	for i in range(1, count):  # Create n-1 notches
		var progress_fraction = float(i) / float(count)
		var x_position = progress_fraction * fill_range - (notch_width / 2)

		var notch = Sprite2D.new()
		notch.texture = notch_texture
		notch.position = Vector2(x_position, 0)
		notch_holder.add_child(notch)
