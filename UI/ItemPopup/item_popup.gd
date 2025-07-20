extends CanvasLayer

#@onready var icon = $Panel/TextureRect
@onready var name_label = $ItemTitle
@onready var flavour_label = $itemDescription

func show_item(info: Dictionary):
	name_label.text = info.get("name", "???")
	flavour_label.text = info.get("flavour", "")
	#icon.texture = info.get("texture", null)
	visible = true

func hide_popup():
	visible = false
