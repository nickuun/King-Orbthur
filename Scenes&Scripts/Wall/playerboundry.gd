extends StaticBody2D  # or whatever it is

func unlock_boundary():
	modulate.a = 0.5
	$CollisionShape2D.set_deferred("disabled", true)
