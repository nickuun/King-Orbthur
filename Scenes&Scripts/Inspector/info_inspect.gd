extends Area2D
class_name InfoInspect

@export var description: String = "Buff does a cool thing"

#func _ready():
	#if is_inside_tree():
		#var overlay = _get_overlay()
		#if overlay:
			#overlay.register_inspector(self)
#
#func _exit_tree():
	#var overlay = _get_overlay()
	#if overlay:
		#overlay.unregister_inspector(self)
#
#func _get_overlay():
	#return get_tree().get_first_node_in_group("InfoOverlay")
