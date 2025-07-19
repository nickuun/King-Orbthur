extends Node

const SEED_LENGTH := 8
const CHARSET := "BCDFGHJKLMNPQRSTVWXYZ0123456789"  # No vowels
var SPECIAL_SEEDS := {
	"GOLDCROP": func(): print("🌟 GOLDEN CROP MODE ENABLED"),
	"BIGHEADS": func(): print("🧠 BIG HEADS MODE")
}

var current_seed: String = ""
var rng := RandomNumberGenerator.new()

func _ready():
	 #Safe default
	set_seed(generate_seed())

func generate_seed() -> String:
	var seed := ""
	for i in SEED_LENGTH:
		seed += CHARSET[randi() % CHARSET.length()]
	return seed

func set_seed(seed_string: String):
	# Strip spaces and uppercase
	var seed_clean = seed_string.strip_edges().replace(" ", "").to_upper()

	# Handle special seeds
	if SPECIAL_SEEDS.has(seed_clean):
		current_seed = seed_clean
		SPECIAL_SEEDS[seed_clean].call()
		# Still randomize to avoid collisions
		rng.seed = hash_djb2(generate_seed())
	else:
		current_seed = seed_clean
		rng.seed = hash_djb2(current_seed)

	print("🔢 Game seed set to:", current_seed)

func get_seed() -> String:
	return current_seed

# Use this to generate reproducible numbers
func randf_range(min_val: float, max_val: float) -> float:
	return rng.randf_range(min_val, max_val)

func randi_range(min_val: int, max_val: int) -> int:
	return rng.randi_range(min_val, max_val)

func randf() -> float:
	return rng.randf()

func randi() -> int:
	return rng.randi()

# Custom hash function to convert string seed to int
func hash_djb2(s: String) -> int:
	var hash := 5381
	for i in s.length():
		hash = ((hash << 5) + hash) + s.unicode_at(i)
	return abs(hash)  # Keep positive

static func shuffle_array(array: Array) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j = SeedManager.randi_range(0, i)
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp
