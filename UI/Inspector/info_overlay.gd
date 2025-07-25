extends CanvasLayer

@onready var fade_rect: Sprite2D
@onready var tooltip: Panel = $Tooltip
@onready var tooltip_label: Label = $Tooltip/Label

var is_inspect_mode: bool = false
var hovered_inspectors: Array[InfoInspect] = []
var lifted_nodes: Array[Node] = []
var original_z_indices := {}


func _ready() -> void:
	#fade_rect.visible = false
	tooltip.visible = false
	fade_rect = get_tree().get_first_node_in_group("InspectOverlay")
	if fade_rect:
		fade_rect.visible = false

func _process(delta: float) -> void:
	var should_enable := Input.is_key_pressed(KEY_ALT)

	if should_enable != is_inspect_mode:
		is_inspect_mode = should_enable

		if fade_rect:
			fade_rect.visible = is_inspect_mode

		tooltip.visible = false
		get_tree().paused = is_inspect_mode

	if not is_inspect_mode:
		hide_tooltip()
		return

	var mouse_pos: Vector2 = get_tree().get_first_node_in_group("World").get_global_mouse_position()

	# --- Hover check ---
	var query := PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var space_state := get_viewport().get_world_2d().direct_space_state
	var results: Array[Dictionary] = space_state.intersect_point(query)

	var current_hovered: Array[InfoInspect] = []

	for result: Dictionary in results:
		var area: Area2D = result.get("collider")
		if area is InfoInspect:
			var inspector := area as InfoInspect
			if inspector.get_parent().visible and inspector.description != "":
				current_hovered.append(inspector)
				if not hovered_inspectors.has(inspector):
					hovered_inspectors.append(inspector)


	# Cleanup stale inspectors
	var cleaned: Array[InfoInspect] = []
	for inspector in hovered_inspectors:
		if current_hovered.has(inspector):
			cleaned.append(inspector)
	hovered_inspectors = cleaned

	# Tooltip logic
	if hovered_inspectors.is_empty():
		hide_tooltip()
	else:
		show_tooltip(hovered_inspectors[0].description, hovered_inspectors[0])

	# Tooltip follow mouse
	var offset: Vector2 = Vector2(16, 16)
	var tooltip_size: Vector2 = tooltip.size
	if tooltip_size == Vector2.ZERO:
		tooltip_size = tooltip.get_combined_minimum_size()

	var new_pos: Vector2 = mouse_pos + offset
	var screen_size: Vector2 = get_viewport().get_visible_rect().size

	if new_pos.x + tooltip_size.x > screen_size.x:
		new_pos.x = mouse_pos.x - tooltip_size.x - offset.x
	if new_pos.y + tooltip_size.y > screen_size.y:
		new_pos.y = mouse_pos.y - tooltip_size.y - offset.y

	tooltip.global_position = new_pos

func show_tooltip(text: String, source_node: Node) -> void:
	tooltip_label.text = text
	tooltip.visible = true

	var parent = source_node.get_parent()
	if parent and parent.has_method("set_z_index") and not lifted_nodes.has(parent):
		original_z_indices[parent] = parent.z_index
		parent.z_index = 999
		lifted_nodes.append(parent)

func hide_tooltip() -> void:
	tooltip.visible = false
	for node in lifted_nodes:
		if node and original_z_indices.has(node):
			node.z_index = original_z_indices[node]
	original_z_indices.clear()
	lifted_nodes.clear()
