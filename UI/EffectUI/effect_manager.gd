extends Control

@export var icon_scene: PackedScene
@export var spacing: int = 4

@onready var spawn_node = $SpawnNode
@onready var destination_node = $DestinationNode

func _ready() -> void:
	self.show()

func add_effect(effect_name: String, texture: Texture2D, duration: float = 5.0):
	for child in destination_node.get_children():
		if child.effect_name == effect_name:
			child.extend_duration(duration)
			return

	var icon = icon_scene.instantiate()
	icon.effect_name = effect_name
	icon.icon_texture = texture
	icon.duration = duration
	destination_node.add_child(icon)
	icon.position = spawn_node.global_position - destination_node.global_position
	icon.move_to(_calculate_target_position(destination_node.get_child_count() - 1))


func reflow_icons():
	var i = 0
	for child in destination_node.get_children():
		if child is Control:
			var target_pos = _calculate_target_position(i)
			child.move_to(target_pos)
			i += 1


func _calculate_target_position(index: int) -> Vector2:
	var x = index * (16 + spacing)
	return Vector2(x, 0)
