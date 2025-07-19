extends Node2D

func _ready():
	$Sprite.animation_finished.connect(queue_free)
