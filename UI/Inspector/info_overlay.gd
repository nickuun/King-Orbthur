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

func _process(_delta: float) -> void:
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

	# For hover detection (world-space)
	var world_mouse_pos: Vector2 = get_tree().get_first_node_in_group("World").get_global_mouse_position()

	# For tooltip positioning (screen-space)
	var screen_mouse_pos: Vector2 = get_viewport().get_mouse_position()

	# --- Hover check ---
	var query := PhysicsPointQueryParameters2D.new()
		# Query at world_mouse_pos
	query.position = world_mouse_pos
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
		if is_instance_valid(inspector) and current_hovered.has(inspector):
			cleaned.append(inspector)
	hovered_inspectors = cleaned

	# Tooltip logic
	if hovered_inspectors.is_empty():
		hide_tooltip()
	else:
		show_tooltip(hovered_inspectors[0].description, hovered_inspectors[0])

	# Tooltip follow mouse
	var offset: Vector2 = Vector2(8, 8)
	var tooltip_size: Vector2 = tooltip.size
	if tooltip_size == Vector2.ZERO:
		tooltip_size = tooltip.get_combined_minimum_size()

		# UI tooltip at screen_mouse_pos
	var new_pos: Vector2 = screen_mouse_pos + offset

	# Get the screen size
	var screen_size: Vector2 = get_viewport().get_visible_rect().size

	# Calculate final tooltip size (accounting for it not being updated yet)
	if tooltip_size == Vector2.ZERO:
		tooltip_size = tooltip.get_combined_minimum_size()

	# Clamp the position so the tooltip stays on-screen
	if new_pos.x + tooltip_size.x > screen_size.x:
		new_pos.x = screen_size.x - tooltip_size.x
	if new_pos.y + tooltip_size.y > screen_size.y:
		new_pos.y = screen_size.y - tooltip_size.y

	# Make sure it doesn't go off the top/left either
	new_pos.x = max(0, new_pos.x)
	new_pos.y = max(0, new_pos.y)

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
