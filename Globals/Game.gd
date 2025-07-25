extends Node

var player: Node = null
var lifebar: Node = null
var seed_offset: int = 0
var coin_label: Label = null
var saved_seed: String = ""  # Make sure this sticks around between restarts
var highscore: int = 0
const SAVE_PATH := "user://highscore.save"

var orb: CharacterBody2D
var floating_text_scene := preload("res://Scenes&Scripts/Tools/FloatingText/floating_text.tscn")
var Seeded: Node = null
var should_keep_seed := false  # default to false
var effect_manager: Node = null

var active_temp_effects := {}


func _ready():
	load_highscore()

func get_seed() -> String:
	return saved_seed

func show_floating_text(text: String, pos: Vector2, color := Color.WHITE, size := 16, duration := 1.5):
	var node := floating_text_scene.instantiate()
	node.global_position = pos
	get_tree().current_scene.add_child(node)
	node.setup(text, color, size, duration)

func has_temp_effect(effect_name: String) -> bool:
	return active_temp_effects.has(effect_name)

func on_orb_collected():
	pass

func save_highscore():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(str(highscore))

func load_highscore():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var line = file.get_line()
			highscore = int(line)

func get_item_by_effect(effect_name: String) -> Dictionary:
	print("🔍 Looking for effect in shop DB:", effect_name)

	for item in ShopDB.shop_items:
		print("🧪 Checking item:", item.effect)
		if item.effect == effect_name:
			print("✅ Found match:", item.name)
			return item

	print("❌ No match found.")
	return {}

func update_coin_ui(coin_count):
	if Game.coin_label:
		Game.coin_label.text = str(coin_count)
