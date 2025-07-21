extends Node

var shop_items := [
	{
		"name": "Heal Up",
		"price": 5,
		"texture": preload("res://Sprites/Pixel_Icons/Alchemy_Potion_Vial_Bottle_Huge_Cube_Square_Empty.png"),
		"effect": "heal",
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Restores a bit of health. Feels good."
	},
	{
		"name": "Speed Syringe",
		"price": 8,
		"texture": preload("res://Sprites/Pixel_Icons/Food_Pizza.png"),
		"effect": "speed_up",
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Increases your base speed permanently."
	},
	{
		"name": "Heart Container",
		"price": 10,
		"texture": preload("res://Sprites/Pixel_Icons/Food_Fruit_Apple.png"),
		"effect": "perm_hp_up",
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Grants extra max lifepoints."
	},
	{
		"name": "Chonker Shroom",
		"price": 6,
		"texture": preload("res://Sprites/Pixel_Icons/Hats_Astronaut_Helm_Space_Suit.png"),
		"effect": "perm_size_speed_trade",
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Grow big. Get slower."
	},
	{
		"name": "Orb Stabilizer",
		"price": 9,
		"texture": preload("res://Sprites/Pixel_Icons/Food_Baby_Pacifier_Easy.png"),
		"effect": "ball_slow",
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Reduces orb speed permanently."
	},
	
]
