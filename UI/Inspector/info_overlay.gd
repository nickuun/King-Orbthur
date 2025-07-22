extends CanvasLayer

@onready var fade_rect := $FadeRect
@onready var tooltip := $Tooltip
@onready var tooltip_label := $Tooltip/Label
var lifted_node: Node = null
var original_z_index: int = 0

var is_inspect_mode := false

func _ready():
	fade_rect.visible = false
	tooltip.visible = false

func _process(delta):
	var should_enable = Input.is_key_pressed(KEY_ALT)

	if should_enable != is_inspect_mode:
		is_inspect_mode = should_enable
		fade_rect.visible = is_inspect_mode
		tooltip.visible = false  # Hide any active tooltip
		get_tree().paused = is_inspect_mode  # 🛑 Pause when in inspect mode

	var mouse_pos = get_viewport().get_mouse_position()
	var offset := Vector2(16, 16)

	# Optional: define size manually
	var tooltip_size = tooltip.size  # or Vector2(200, 80) if you want a fixed size

	# Fallback if not set yet
	if tooltip_size == Vector2.ZERO:
		tooltip_size = tooltip.get_combined_minimum_size()

	# Default position (bottom-right of mouse)
	var new_pos = mouse_pos + offset

	# Viewport boundary
	var screen_size = get_viewport().get_visible_rect().size

	# Clamp to screen
	if new_pos.x + tooltip_size.x > screen_size.x:
		new_pos.x = mouse_pos.x - tooltip_size.x - offset.x

	if new_pos.y + tooltip_size.y > screen_size.y:
		new_pos.y = mouse_pos.y - tooltip_size.y - offset.y

	tooltip.global_position = new_pos


func show_tooltip(text: String, source_node: Node):
	if is_inspect_mode:
		tooltip_label.text = text
		tooltip.visible = true

		# Lift parent above ColorRect
		if source_node and source_node.get_parent():
			lifted_node = source_node.get_parent()
			if lifted_node.has_method("set_z_index"):
				original_z_index = lifted_node.z_index
				lifted_node.z_index = 9999

func hide_tooltip():
	tooltip.visible = false

	if lifted_node and lifted_node.has_method("set_z_index"):
		lifted_node.z_index = original_z_index
		lifted_node = null
