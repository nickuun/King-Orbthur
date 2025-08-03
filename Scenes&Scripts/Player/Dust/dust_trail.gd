extends Node2D

func _ready():
	self.scale = Game.player.scale
	$Sprite.animation_finished.connect(queue_free)
