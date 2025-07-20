extends StaticBody2D  # or whatever it is

func unlock_boundary():
	modulate.a = 0.1
	$CollisionShape2D.set_deferred("disabled", true)
	
func lock_boundary():
	modulate.a = 1.0
	$CollisionShape2D.set_deferred("disabled", false)
