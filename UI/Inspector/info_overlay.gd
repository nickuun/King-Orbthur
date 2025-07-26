extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect
@onready var tooltip: Panel = $Tooltip
@onready var tooltip_label: Label = $Tooltip/Label

var is_inspect_mode: bool = false
var hovered_inspectors: Array[InfoInspect] = []
var lifted_node: Node = null
var original_z_index: int = 0

func _ready() -> void:
	fade_rect.visible = false
	tooltip.visible = false

func _process(delta: float) -> void:
	var should_enable := Input.is_key_pressed(KEY_ALT)

	if should_enable != is_inspect_mode:
		is_inspect_mode = should_enable
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

	if source_node.get_parent() and source_node.get_parent().has_method("set_z_index"):
		if lifted_node and lifted_node != source_node.get_parent():
			lifted_node.z_index = original_z_index
		lifted_node = source_node.get_parent()
		original_z_index = lifted_node.z_index
		lifted_node.z_index = 999

func hide_tooltip() -> void:
	tooltip.visible = false
	if lifted_node and lifted_node.has_method("set_z_index"):
		lifted_node.z_index = original_z_index
		lifted_node = null
