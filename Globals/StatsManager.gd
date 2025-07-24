# StatsManager.gd
extends Node


# -- Orb Stats --
var ball_speed_multiplier: float = 1.0
var ball_base_speed := 250.0
var ball_base_scale := Vector2(1, 1)
var ball_scale_multiplier := 1.0
# -- Player Stats --
var player_base_speed := 100.0
var player_speed_multiplier := 1.0
var player_base_scale := Vector2(1, 1)
var player_scale_multiplier := 1.0
# -- Coin Drops --
var coin_drop_rate := 0.1  # 10% by default
var coin_drop_guaranteed := false

func reset():
	ball_speed_multiplier = 1.0
	ball_base_speed = 250.0
	
func get_final_player_speed() -> float:
	return player_base_speed * player_speed_multiplier

func get_final_player_scale() -> Vector2:
	return player_base_scale * player_scale_multiplier

func get_final_ball_speed() -> float:
	return ball_base_speed * ball_speed_multiplier

func get_final_orb_scale() -> Vector2:
	return ball_base_scale * ball_scale_multiplier
