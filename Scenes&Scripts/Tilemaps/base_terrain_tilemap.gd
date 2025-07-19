extends Node2D

@export var tile_size := 16
@export var radius_x := 30
@export var radius_y := 10
@export var grass_tile_light := Vector2i(2, 1)
@export var grass_tile_dark := Vector2i(16, 4)
@export var flower_tiles : Array[Vector2i] = [
	Vector2i(27, 1), Vector2i(28, 1), Vector2i(29, 1), Vector2i(30, 1), Vector2i(31, 1), Vector2i(32, 1), Vector2i(33, 1), Vector2i(34, 1),
	Vector2i(27, 2), Vector2i(28, 2), Vector2i(29, 2), Vector2i(30, 2), Vector2i(31, 2), Vector2i(32, 2), Vector2i(33, 2), Vector2i(34, 2),
	Vector2i(27, 3), Vector2i(28, 3), Vector2i(29, 3), Vector2i(30, 3), Vector2i(31, 3), Vector2i(32, 3), Vector2i(33, 3), Vector2i(34, 3),
	Vector2i(34, 4)
]

func _process(_delta):
	var player = Game.player
	if not player:
		return

	var center = player.global_position / tile_size
	var center_cell = Vector2i(center.x, center.y)

	var grass = $GrassLayer
	var flowers = $FlowerLayer

	grass.clear()
	flowers.clear()

	for x in range(center_cell.x - radius_x, center_cell.x + radius_x):
		for y in range(center_cell.y - radius_y, center_cell.y + radius_y + 2):  # extra rows downward
			var coords = Vector2i(x, y)

			# Checkerboard grass
			var is_even = (x + y) % 2 == 0
			var grass_tile = grass_tile_light if is_even else grass_tile_dark
			grass.set_cell(coords, 0, grass_tile)

			# Deterministic flower generation
			var hash_val = SeedManager.hash_djb2(str(coords + Vector2i(Game.seed_offset, Game.seed_offset)))

			var rng = RandomNumberGenerator.new()
			rng.seed = int(hash_val)
			if rng.randi_range(0, 99) < 10:
				var flower_index = rng.randi_range(0, flower_tiles.size() - 1)
				var flower = flower_tiles[flower_index]
				flowers.set_cell(coords, 0, flower)
