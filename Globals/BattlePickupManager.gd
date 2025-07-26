# BattlePickupManager.gd
extends Node

func apply(pickup_type: String, receiver: Node) -> void:
	var effect_data = Game.get_item_by_effect(pickup_type)

	# ✅ Show icon if texture available
	if effect_data and effect_data.has("texture") and is_instance_valid(Game.effect_manager):
		Game.effect_manager.add_effect(pickup_type, effect_data.texture, 5.0, effect_data.flavour )
	
	# Determine duration
	var base_duration: float = 5.0
	if effect_data and effect_data.has("duration"):
		base_duration = effect_data.duration
	var duration: float = base_duration * StatsManager.battle_pickup_time_modifier


	match pickup_type:
		"temp_ball_slow":
			receiver.apply_temporary_effect(
				"temp_ball_slow",
				duration,
				func(): StatsManager.ball_speed_multiplier *= 0.5,
				func(): StatsManager.ball_speed_multiplier /= 0.5
			)

		"temp_ball_grow":
			receiver.apply_temporary_effect(
				"temp_ball_grow",
				duration,
				func():
					var tween = Game.orb.create_tween()
					tween.tween_property(Game.orb, "scale", Vector2(2, 2), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT),
				func():
					var tween = Game.orb.create_tween()
					tween.tween_property(Game.orb, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			)

		"temp_player_grow":
			receiver.apply_temporary_effect(
				"temp_player_grow",
				duration,
				func():
					var tween = receiver.create_tween()
					tween.tween_property(receiver, "scale", Vector2(2, 2), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT),
				func():
					var tween = receiver.create_tween()
					tween.tween_property(receiver, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			)

		"temp_speed_up":
			receiver.apply_temporary_effect(
				"temp_speed_up",
				duration,
				func(): StatsManager.player_speed_multiplier *= 1.5,
				func(): StatsManager.player_speed_multiplier /= 1.5
			)

		"perm_speed_up":
			StatsManager.player_base_speed += 20

		"perm_shop_discount":
			Game.shop_discount = 0.8

		"temp_coin_hit":
			receiver.apply_temporary_effect(
				"temp_coin_hit",
				duration,
				func(): StatsManager.coin_drop_guaranteed = true,
				func(): StatsManager.coin_drop_guaranteed = false
			)

		"heal":
			receiver.current_health = min(receiver.current_health + 10, receiver.max_health)
			receiver.update_lifebar()

		_:
			print("⚠️ Unknown pickup type:", pickup_type)
