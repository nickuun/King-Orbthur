extends Node2D

class_name ActiveItem
@export var item_name: String = "Default Active"
@export var icon: Texture
@export var max_charges: int = 3
@export var current_charges: int = 3
@export var cooldown: float = 0.0  # Optional: time before next use
@export var flavour: String = ""
@export var on_activate_func: Callable

var is_on_cooldown := false

func _ready():
	current_charges = max_charges

func add_charge(amount: int = 1):
	if current_charges < max_charges:
		current_charges += amount
		print(item_name, "gained charge: ", current_charges)

func try_activate():
	if is_on_cooldown:
		print("⏳", item_name, "is on cooldown!")
		return
	
	if current_charges < max_charges:
		print("🪫", item_name, "not fully charged! (", current_charges, "/", max_charges, ")")
		return

	# Spend all charges when used
	current_charges = 0
	print("✅ Activated:", item_name, "Charges left:", current_charges)

	if on_activate_func:
		on_activate_func.call()

	if cooldown > 0:
		is_on_cooldown = true
		var cd_timer := Timer.new()
		cd_timer.one_shot = true
		cd_timer.wait_time = cooldown
		add_child(cd_timer)
		cd_timer.connect("timeout", Callable(self, "_on_cooldown_done"))
		cd_timer.start()

func _on_cooldown_done():
	is_on_cooldown = false
