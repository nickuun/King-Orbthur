extends Area2D
class_name InfoInspect

@export var description: String = "Buff does a cool thing"
var tooltip_visible := false

func _process(delta):
	if not Input.is_key_pressed(KEY_ALT):
		if tooltip_visible:
			_get_overlay().hide_tooltip()
			tooltip_visible = false
		return

	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = []

	var result = get_world_2d().direct_space_state.intersect_point(query)

	var is_hovered := false
	for hit in result:
		if hit.collider == self:
			is_hovered = true
			break

	if is_hovered and not tooltip_visible:
		_get_overlay().show_tooltip(description, self)
		tooltip_visible = true
	elif not is_hovered and tooltip_visible:
		_get_overlay().hide_tooltip()
		tooltip_visible = false

func _get_overlay():
	return get_tree().get_first_node_in_group("InfoOverlay")
