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
	# ⚠️ Skip if only 1 charge — no need for notches
	if count <= 1:
		return

	var bar_width = $ChargeBar.size.x
	var notch_width = notch_texture.get_width()

	for i in range(1, count):  # We want NOTCHES BETWEEN values
		var progress_fraction = float(i) / float(count)  # e.g. 1/3, 2/3 for 3 charges
		var x_position = progress_fraction * bar_width - (notch_width / 2)

		var notch = Sprite2D.new()
		notch.texture = notch_texture
		notch.position = Vector2(x_position, 0)
		$NotchHolder.add_child(notch)
