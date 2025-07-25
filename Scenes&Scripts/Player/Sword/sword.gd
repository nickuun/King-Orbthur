extends Node2D

func swing_sword():
	if Game.orb and Game.orb.state == Game.orb.BallState.NORMAL:
		if Game.player.sword_side == "left": 
			Game.player.sword.get_node("Sprite").play("SwingRight")
			Game.player.sword_desired_offset = 180
			Game.player.sword_side = "right"
		else:
			Game.player.sword.get_node("Sprite").play("SwingLeft")
			Game.player.sword_side = "left"
			Game.player.sword_desired_offset = -180
	else:
		print("⚠️ Can't swing — ball is frozen, returning, or gone.")
