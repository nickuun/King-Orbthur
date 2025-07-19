extends Node

var player: Node = null
var lifebar: Node = null
var seed_offset: int = 0
var coin_label: Label = null
var orb: CharacterBody2D
var floating_text_scene := preload("res://Scenes&Scripts/Tools/FloatingText/floating_text.tscn")
var Seeded: Node = null
var should_keep_seed := false  # default to false

static func freeze_orb():
	if is_instance_valid(Game.orb):
		Game.orb.freeze_and_return_to_player()

func get_seed() -> String:
	return SeedManager.get_seed()

func show_floating_text(text: String, pos: Vector2, color := Color.WHITE, size := 16, duration := 1.5):
	var node := floating_text_scene.instantiate()
	node.global_position = pos
	get_tree().current_scene.add_child(node)
	node.setup(text, color, size, duration)
