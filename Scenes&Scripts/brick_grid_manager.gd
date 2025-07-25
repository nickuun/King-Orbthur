extends Node2D

@export var bricks: PackedScene
@export var chest_bricks: PackedScene
@export var locked_door_scene: PackedScene

@export var key_scene: PackedScene
var key_index := -1
var key_brick_index := -1  # Add this to the top
var key_granted := false

@export var max_rows: int = 6
@export var total_columns: int = 16
@export var column_spacing: float = 25.0
@export var row_spacing: float = 25.0

@export var chest_min: int = 1
@export var chest_max: int = 2
@export var chest_cap: int = 24

var bricks_remaining := 0
var stage_bricks_remaining := 0
var spawn_stage := 0
var current_column_index := 0

var chest_indexes: Array = []       # global flat indices for the entire level
var stage_brick_index := 0          # total bricks spawned, used to map chest index
var door_spawned := false
var level_start_offset: Vector2 = Vector2.ZERO  # Used to shift spawn position each loop
var queued_stage_spawn: bool = false


func _ready():
	# Force re-apply the seed BEFORE using it
	if Game.should_keep_seed:
		SeedManager.set_seed(Game.get_seed())
	else:
		var new_seed = SeedManager.generate_seed()
		Game.saved_seed = new_seed
		SeedManager.set_seed(new_seed)

	# Now proceed with generation
	_generate_chest_indexes()
	_spawn_next_stage()


func _generate_chest_indexes():
	var pool := []
	for i in chest_cap:
		pool.append(i)
	SeedManager.shuffle_array(pool)
	print("🧰 Chest pool after shuffle:", pool)


	# Log first few randoms
	print("🔍 RNG sample:", SeedManager.randi(), SeedManager.randi(), SeedManager.randf())

	chest_indexes.append(pool[0])
	if chest_max > chest_min and SeedManager.randf() < 0.5:
		chest_indexes.append(pool[1])

	print("🧰 Chests (flat indices):", chest_indexes)


func _spawn_next_columns(column_count: int) -> void:
	await _spawn_columns_sequentially(column_count)

func _spawn_columns_sequentially(count: int) -> void:
	for i in range(count):
		if current_column_index >= total_columns:
			print("🏁 All columns spawned!")
			return

		var x = level_start_offset.x + current_column_index * column_spacing


		for row_index in range(max_rows):
			var brick = chest_bricks.instantiate() if chest_indexes.has(stage_brick_index) else bricks.instantiate()
			
			#if stage_brick_index == key_brick_index:
				#if is_instance_valid(brick) and "drops_key" in brick:
					#brick.drops_key = true
					#print("✅ Marked brick index %d to drop key" % stage_brick_index)

			brick.position = Vector2(x, row_index * row_spacing)
			brick.stage_index = stage_brick_index
			brick.connect("brick_destroyed", Callable(self, "_on_brick_destroyed"))
			$LevelContainer.call_deferred("add_child", brick)

			bricks_remaining += 1
			stage_bricks_remaining += 1
			stage_brick_index += 1  # ✅ this is critica

		print("🧱 Spawned column", current_column_index)
		current_column_index += 1

		# Smooth scroll
		var edge = get_tree().get_first_node_in_group("EdgeContainers")
		var from_pos = edge.position
		var to_pos = from_pos + Vector2(column_spacing, 0)

		var tween = create_tween()
		tween.tween_property(edge, "position", to_pos, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tween.finished

func _spawn_next_stage():
	stage_bricks_remaining = 0
	

	match spawn_stage:
		0:
			_spawn_next_columns(1)
			#_spawn_locked_door_column()
		1: _spawn_next_columns(2)
		2: _spawn_next_columns(3)
		3: _spawn_next_columns(1)
		_: 
			print("⚠️ No more stages defined!")
			return

	spawn_stage += 1



func _on_brick_destroyed(_brick):
	bricks_remaining -= 1
	stage_bricks_remaining -= 1

	if not door_spawned and bricks_remaining == 12:
		_spawn_locked_door_column()
	
	if !door_spawned:
		if spawn_stage == 3 and stage_bricks_remaining == (3 * max_rows) - max_rows:
			_try_queue_or_spawn_next_stage()
		elif stage_bricks_remaining <= 0:
			_try_queue_or_spawn_next_stage()

func _try_queue_or_spawn_next_stage():
	if queued_stage_spawn:
		return

	print("⏳ Queued stage spawn — waiting for orb to move right")
	queued_stage_spawn = true



func _spawn_locked_door_column():
	door_spawned = true
	print("🚪 Spawning locked door!")

	# 🔐 Find a valid, active brick to drop the key
	var candidates := []
	for brick in $LevelContainer.get_children():
		if brick.has_method("_on_hit") and not brick.is_queued_for_deletion():
			candidates.append(brick)

	if candidates.size() > 0:
		var chosen = candidates[SeedManager.randi_range(0, candidates.size() - 1)]
		chosen.drops_key = true
		print("✅ Key assigned to visible brick:", chosen.name, "at stage index", chosen.stage_index)
	else:
		print("⚠️ No valid bricks to assign key!")

	# 🚪 Spawn the actual locked door
	var door := locked_door_scene.instantiate()
	var x = current_column_index * column_spacing
	door.position = Vector2(x, 0)
	$LevelContainer.add_child(door)

	# 👉 Smooth scroll
	var edge = get_tree().get_first_node_in_group("EdgeContainers")
	var from_pos = edge.position
	var to_pos = from_pos + Vector2(column_spacing, 0)

	var tween = create_tween()
	tween.tween_property(edge, "position", to_pos, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	current_column_index += 1

func reset_level(new_start_offset: Vector2 = Vector2.ZERO):
	for child in $LevelContainer.get_children():
		child.queue_free()
	
	var brick_spawn_spot = get_tree().get_first_node_in_group("BrickSpawnSpot")
	self.global_position = brick_spawn_spot.global_position
	
	bricks_remaining = 0
	stage_bricks_remaining = 0
	current_column_index = 0
	stage_brick_index = 0
	spawn_stage = 0
	door_spawned = false
	chest_indexes.clear()
	_generate_chest_indexes()
	_spawn_next_stage()
	get_tree().get_first_node_in_group("World").respawn_ball()

func _on_freeze_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ball"):
		if queued_stage_spawn :
			print("✅ Orb on right — spawning queued stage")
			queued_stage_spawn = false
			_spawn_next_stage()

func _on_back_wall_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ball"):
		if queued_stage_spawn :
			print("✅ Orb on right — spawning queued stage")
			queued_stage_spawn = false
			_spawn_next_stage()
